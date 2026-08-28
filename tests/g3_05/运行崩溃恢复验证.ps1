[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName
$godotExecutable = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
$expectedHelperExecutable = [IO.Path]::GetFullPath('D:\AI\Engine\Godot_v4.7.2-stable_win64.exe')
$testRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_05_crash_test'))
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_05_crash_test'))
if (-not $testRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    -not $testRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase) -or
    (Split-Path -Leaf $testRoot) -ne 'g3_05_crash_test') {
    throw "Refusing unsafe G3-05 crash path: $testRoot"
}
if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
New-Item -ItemType Directory -Path $testRoot | Out-Null

$database = (Join-Path $testRoot 'crash.sqlite').Replace('\', '/')
$proof = (Join-Path $testRoot 'proof.json').Replace('\', '/')
$helper = 'res://tests/g3_05/保护切换提交后崩溃助手.gd'

function Invoke-Helper {
    param([string]$Mode, [string]$LogName, [string]$Marker = '')
    $arguments = @('--headless', '--path', $projectRoot, '--log-file', (Join-Path $testRoot $LogName), '--script', $helper, '--', "--mode=$Mode", "--db=$database", "--proof=$proof")
    if (-not [string]::IsNullOrWhiteSpace($Marker)) { $arguments += "--marker=$Marker" }
    & $godotExecutable @arguments
    if ($LASTEXITCODE -ne 0) { throw "G3-05 crash helper failed: $Mode" }
}

function Invoke-CommitThenKill {
    param([string]$Mode, [string]$MarkerName, [string]$LogName)
    $marker = (Join-Path $testRoot $MarkerName).Replace('\', '/')
    $arguments = @('--headless', '--path', $projectRoot, '--log-file', (Join-Path $testRoot $LogName), '--script', $helper, '--', "--mode=$Mode", "--db=$database", "--proof=$proof", "--marker=$marker")
    $process = Start-Process -FilePath $godotExecutable -ArgumentList $arguments -WindowStyle Hidden -PassThru
    for ($attempt = 0; $attempt -lt 200; $attempt += 1) {
        if ((Test-Path -LiteralPath $marker -PathType Leaf) -or $process.HasExited) { break }
        Start-Sleep -Milliseconds 50
    }
    if (-not (Test-Path -LiteralPath $marker -PathType Leaf)) {
        if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
        throw "$Mode COMMIT marker was not observed."
    }
    $markerValue = Get-Content -Raw -LiteralPath $marker | ConvertFrom-Json
    if (-not [bool]$markerValue.committed) { throw "$Mode marker did not confirm COMMIT." }
    $exactPid = [int]$markerValue.pid
    $helperProcess = Get-Process -Id $exactPid -ErrorAction SilentlyContinue
    if ($null -eq $helperProcess) { throw "Marker-confirmed helper PID already exited: $exactPid" }
    $actualHelper = [IO.Path]::GetFullPath($helperProcess.MainModule.FileName)
    if (-not $actualHelper.Equals($expectedHelperExecutable, [StringComparison]::OrdinalIgnoreCase)) {
        if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
        throw "Refusing identity-ambiguous helper PID $exactPid at $actualHelper"
    }
    $helperProcess.Kill(); $helperProcess.WaitForExit()
    if (-not $process.HasExited) { $process.WaitForExit(10000) | Out-Null }
    Write-Output "G3-05 CRASH | $Mode exact PID terminated after COMMIT: $exactPid"
}

Invoke-Helper -Mode 'seed' -LogName 'seed.log'
Invoke-CommitThenKill -Mode 'load-commit-wait' -MarkerName 'load-committed.json' -LogName 'load-commit.log'
Invoke-Helper -Mode 'verify-load-seed-branch' -LogName 'verify-load.log'
Invoke-CommitThenKill -Mode 'recover-commit-wait' -MarkerName 'recover-committed.json' -LogName 'recover-commit.log'
Invoke-Helper -Mode 'verify-recover' -LogName 'verify-recover.log'
Write-Output 'G3-05 CRASH PASS | protected Load and Recover survived exact-PID death before memory/UI apply'
