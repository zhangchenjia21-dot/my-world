[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName
$godotExecutable = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
$testRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_04_crash_test'))
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_04_crash_test'))
if (-not $testRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    -not $testRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase) -or
    (Split-Path -Leaf $testRoot) -ne 'g3_04_crash_test') {
    throw "Refusing unsafe G3-04 crash path: $testRoot"
}
if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
New-Item -ItemType Directory -Path $testRoot | Out-Null

$database = (Join-Path $testRoot 'crash.sqlite').Replace('\', '/')
$proof = (Join-Path $testRoot 'proof.json').Replace('\', '/')
$marker = (Join-Path $testRoot 'committed.json').Replace('\', '/')
$helper = 'res://tests/g3_04/提交后崩溃恢复助手.gd'

& $godotExecutable --headless --path $projectRoot --log-file (Join-Path $testRoot 'seed.log') --script $helper -- --mode=seed "--db=$database" "--proof=$proof"
if ($LASTEXITCODE -ne 0) { throw 'G3-04 crash seed failed.' }

$arguments = @('--headless', '--path', $projectRoot, '--log-file', (Join-Path $testRoot 'commit.log'), '--script', $helper, '--', '--mode=restore-commit-wait', "--db=$database", "--proof=$proof", "--marker=$marker")
$process = Start-Process -FilePath $godotExecutable -ArgumentList $arguments -WindowStyle Hidden -PassThru
for ($attempt = 0; $attempt -lt 200; $attempt += 1) {
    if ((Test-Path -LiteralPath $marker -PathType Leaf) -or $process.HasExited) { break }
    Start-Sleep -Milliseconds 50
}
if (-not (Test-Path -LiteralPath $marker -PathType Leaf)) {
    if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
    throw 'Restore COMMIT marker was not observed.'
}
$markerValue = Get-Content -Raw -LiteralPath $marker | ConvertFrom-Json
if (-not [bool]$markerValue.committed) {
    if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
    throw 'Restore helper marker did not confirm COMMIT.'
}
$exactPid = [int]$markerValue.pid
$helperProcess = Get-Process -Id $exactPid -ErrorAction SilentlyContinue
if ($null -eq $helperProcess) {
    if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
    throw "Marker-confirmed helper PID already exited: $exactPid"
}
$actualHelper = [IO.Path]::GetFullPath($helperProcess.MainModule.FileName)
$expectedHelper = [IO.Path]::GetFullPath('D:\AI\Engine\Godot_v4.7.2-stable_win64.exe')
if (-not $actualHelper.Equals($expectedHelper, [StringComparison]::OrdinalIgnoreCase)) {
    if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
    throw "Refusing identity-ambiguous helper PID $exactPid at $actualHelper"
}
$helperProcess.Kill()
$helperProcess.WaitForExit()
if (-not $process.HasExited) { $process.WaitForExit(10000) | Out-Null }

& $godotExecutable --headless --path $projectRoot --log-file (Join-Path $testRoot 'verify.log') --script $helper -- --mode=verify "--db=$database" "--proof=$proof"
if ($LASTEXITCODE -ne 0) { throw 'G3-04 crash reopen verification failed.' }
Write-Output "G3-04 CRASH PASS | Restore COMMIT survived exact-PID termination before memory/UI apply: $exactPid"
