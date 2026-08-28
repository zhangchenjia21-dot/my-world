[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName
$godotConsole = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
$godotRuntime = [IO.Path]::GetFullPath('D:\AI\Engine\Godot_v4.7.2-stable_win64.exe')
$testRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_06_crash'))
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_06_crash'))
if (-not $testRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    -not $testRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing unsafe G3-06 crash root: $testRoot"
}
if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
New-Item -ItemType Directory -Path $testRoot | Out-Null

function Invoke-Fixture {
    param([string]$Mode, [string]$Database, [string]$Log)
    & $godotConsole --headless --path $projectRoot --log-file (Join-Path $testRoot $Log) `
        --script 'res://tests/g3_06/安全流程崩溃夹具.gd' -- ("--mode=$Mode") ("--db=$Database")
    if ($LASTEXITCODE -ne 0) { throw "Fixture failed: $Mode" }
}

function Stop-AtCrashPoint {
    param([string]$Operation, [string]$Point, [string]$Database)
    $safePoint = $Point.Replace('_', '-')
    $ready = Join-Path $testRoot ("$safePoint.ready")
    $arguments = @(
        '--headless', '--path', $projectRoot,
        '--log-file', (Join-Path $testRoot ("$safePoint.godot.log")),
        '--script', 'res://tests/g3_06/安全流程崩溃助手.gd', '--',
        ("--operation=$Operation"), ("--point=$Point"), ("--db=$Database"),
        ('--ready={0}' -f $ready.Replace('\', '/'))
    )
    $wrapper = Start-Process -FilePath $godotConsole -ArgumentList $arguments -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $testRoot ("$safePoint.stdout.log")) `
        -RedirectStandardError (Join-Path $testRoot ("$safePoint.stderr.log")) -PassThru
    for ($attempt = 0; $attempt -lt 200 -and -not (Test-Path -LiteralPath $ready -PathType Leaf); $attempt += 1) {
        if ($wrapper.HasExited) { break }
        Start-Sleep -Milliseconds 50
    }
    if (-not (Test-Path -LiteralPath $ready -PathType Leaf)) { throw "Crash point not reached: $Point" }
    $runtimePid = [int]((Get-Content -LiteralPath $ready | Where-Object { $_ -like 'pid=*' }) -replace '^pid=', '')
    $runtimeProcess = Get-Process -Id $runtimePid -ErrorAction Stop
    $actual = [IO.Path]::GetFullPath($runtimeProcess.MainModule.FileName)
    if (-not $actual.Equals($godotRuntime, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Crash helper identity mismatch for PID ${runtimePid}: $actual"
    }
    $runtimeProcess.Kill()
    $runtimeProcess.WaitForExit()
    Write-Output "G3-06 CRASH EVIDENCE | $Point exact PID $runtimePid terminated"
}

$backupStagingDb = (Join-Path $testRoot 'backup-staging.sqlite').Replace('\', '/')
Invoke-Fixture 'seed_backup' $backupStagingDb 'seed-backup-staging.log'
Stop-AtCrashPoint 'backup' 'backup_staging_verified' $backupStagingDb
Invoke-Fixture 'verify_backup' $backupStagingDb 'verify-backup-staging.log'

$rotationDb = (Join-Path $testRoot 'rotation.sqlite').Replace('\', '/')
Invoke-Fixture 'seed_backup' $rotationDb 'seed-rotation.log'
Stop-AtCrashPoint 'backup' 'latest_rotated' $rotationDb
Invoke-Fixture 'verify_backup' $rotationDb 'verify-rotation.log'

$quarantineDb = (Join-Path $testRoot 'quarantine.sqlite').Replace('\', '/')
Invoke-Fixture 'seed_corrupt' $quarantineDb 'seed-quarantine.log'
Stop-AtCrashPoint 'recovery' 'current_quarantined' $quarantineDb
Invoke-Fixture 'verify_retry' $quarantineDb 'verify-quarantine-retry.log'

$publishedDb = (Join-Path $testRoot 'published.sqlite').Replace('\', '/')
Invoke-Fixture 'seed_corrupt' $publishedDb 'seed-published.log'
Stop-AtCrashPoint 'recovery' 'replacement_published' $publishedDb
Invoke-Fixture 'verify_published' $publishedDb 'verify-published.log'

Write-Output 'G3-06 CRASH PASS | backup rotation and disaster recovery remain safe across exact-PID interruption'
