[CmdletBinding()]
param(
    [switch]$SkipRegressions,
    [switch]$SkipExport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName
$godotConsole = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
$testRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_06_test'))
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_06_test'))
if (-not $testRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    -not $testRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing unsafe G3-06 root: $testRoot"
}
if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
New-Item -ItemType Directory -Path $testRoot | Out-Null

function Invoke-GodotScript {
    param([string]$Script, [string[]]$Arguments, [string]$Log)
    & $godotConsole --headless --path $projectRoot --log-file (Join-Path $testRoot $Log) --script $Script -- @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Godot script failed: $Script" }
}

$slashRoot = $testRoot.Replace('\', '/')
Invoke-GodotScript 'res://tests/g3_06/SQLite在线备份契约测试.gd' @("--root=$slashRoot/spike") 'online-spike.log'
Invoke-GodotScript 'res://tests/g3_06/数据库安全流程测试.gd' @("--root=$slashRoot/focused") 'focused.log'
Invoke-GodotScript 'res://tests/g3_06/灾难恢复界面测试.gd' @("--db=$slashRoot/ui/current.sqlite") 'ui.log'
& (Join-Path $PSScriptRoot '运行单写者验证.ps1')
& (Join-Path $PSScriptRoot '运行安全流程崩溃验证.ps1')

if (-not $SkipRegressions) {
    & (Join-Path $projectRoot 'tests\g3_05\运行真实验证.ps1') -SkipExport
}

if (-not $SkipExport) {
    $exportRoot = Join-Path $projectRoot 'build\windows'
    New-Item -ItemType Directory -Force -Path $exportRoot | Out-Null
    $exportExecutable = Join-Path $exportRoot 'my-world-g3-06.exe'
    & $godotConsole --headless --path $projectRoot --log-file (Join-Path $testRoot 'export-build.log') `
        --export-debug 'Windows Desktop' $exportExecutable
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $exportExecutable -PathType Leaf)) {
        throw 'G3-06 Windows Desktop export failed.'
    }

    $singleDb = (Join-Path $testRoot 'export-single.sqlite').Replace('\', '/')
    $ready = Join-Path $testRoot 'export-owner.ready'
    $ownerArgs = @(
        '--headless', '--log-file', (Join-Path $testRoot 'export-owner.log'), '--',
        ("--current-game-db=$singleDb"), '--g3-06-smoke-mode=hold',
        ('--g3-06-ready={0}' -f $ready.Replace('\', '/'))
    )
    $owner = Start-Process -FilePath $exportExecutable -ArgumentList $ownerArgs -WindowStyle Hidden -PassThru
    for ($attempt = 0; $attempt -lt 300 -and -not (Test-Path -LiteralPath $ready -PathType Leaf); $attempt += 1) {
        if ($owner.HasExited) { break }
        Start-Sleep -Milliseconds 50
    }
    if (-not (Test-Path -LiteralPath $ready -PathType Leaf)) { throw 'Exported owner did not reach READY.' }
    $ownerPid = [int]((Get-Content -LiteralPath $ready | Where-Object { $_ -like 'pid=*' }) -replace '^pid=', '')
    $ownerRuntime = Get-Process -Id $ownerPid -ErrorAction Stop
    $actualOwnerExecutable = [IO.Path]::GetFullPath($ownerRuntime.MainModule.FileName)
    if (-not $actualOwnerExecutable.Equals([IO.Path]::GetFullPath($exportExecutable), [StringComparison]::OrdinalIgnoreCase)) {
        throw "Export owner identity mismatch for PID ${ownerPid}: $actualOwnerExecutable"
    }
    $blocked = Start-Process -FilePath $exportExecutable -ArgumentList @(
        '--headless', '--log-file', (Join-Path $testRoot 'export-blocked.log'), '--',
        ("--current-game-db=$singleDb"), '--g3-06-smoke-mode=expect_blocked'
    ) -WindowStyle Hidden -Wait -PassThru
    if ($blocked.ExitCode -ne 0) { throw 'Exported second process was not rejected.' }
    $ownerRuntime.Kill()
    $ownerRuntime.WaitForExit()
    Write-Output "G3-06 EXPORT EVIDENCE | single writer owner exact PID $ownerPid terminated"

    $recoveryDb = (Join-Path $testRoot 'export-recovery.sqlite').Replace('\', '/')
    Invoke-GodotScript 'res://tests/g3_06/安全流程崩溃夹具.gd' @('--mode=seed_corrupt', "--db=$recoveryDb") 'export-recovery-seed.log'
    $recoveryRun = Start-Process -FilePath $exportExecutable -ArgumentList @(
        '--headless', '--log-file', (Join-Path $testRoot 'export-recovery.log'), '--',
        ("--current-game-db=$recoveryDb"), '--g3-06-smoke-mode=recover'
    ) -WindowStyle Hidden -Wait -PassThru
    if ($recoveryRun.ExitCode -ne 0) { throw 'Exported product recovery publication failed.' }
    $reopenRun = Start-Process -FilePath $exportExecutable -ArgumentList @(
        '--headless', '--log-file', (Join-Path $testRoot 'export-reopen.log'), '--',
        ("--current-game-db=$recoveryDb"), '--g3-06-smoke-mode=expect_recovered'
    ) -WindowStyle Hidden -Wait -PassThru
    if ($reopenRun.ExitCode -ne 0) { throw 'Exported recovered current did not reopen.' }
    Write-Output 'G3-06 EXPORT PASS | Windows Desktop EXE single-instance + staged recovery + reopen'
}

git -C $projectRoot diff --check
if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed.' }
Write-Output 'G3-06 PASS | full engineering validation completed'
