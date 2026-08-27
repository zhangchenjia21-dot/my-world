[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName
$godotExecutable = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
$testRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_02_test'))
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_02_test'))

if (-not (Test-Path -LiteralPath $godotExecutable -PathType Leaf)) { throw "Godot executable not found: $godotExecutable" }
if (-not $testRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    -not $testRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase) -or
    (Split-Path -Leaf $testRoot) -ne 'g3_02_test') {
    throw "Refusing unsafe G3-02 test path: $testRoot"
}
if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
New-Item -ItemType Directory -Path $testRoot | Out-Null

function Invoke-GodotScript {
    param([string]$Script, [string[]]$UserArguments, [string]$LogName)
    & $godotExecutable --headless --path $projectRoot --log-file (Join-Path $testRoot $LogName) --script $Script -- @UserArguments
    if ($LASTEXITCODE -ne 0) { throw "Godot script failed ($LASTEXITCODE): $Script" }
}

$slashRoot = $testRoot.Replace('\', '/')
Invoke-GodotScript -Script 'res://tests/g3_02/世界持久化流程测试.gd' -UserArguments @(('--root={0}' -f $slashRoot)) -LogName 'focused.log'
Invoke-GodotScript -Script 'res://tests/g3_02/查询失败传播测试.gd' -UserArguments @(('--root={0}' -f $slashRoot)) -LogName 'query-failure.log'

$lostAckDatabase = (Join-Path $testRoot 'lost-ack.sqlite').Replace('\', '/')
$marker = Join-Path $testRoot 'post-commit.marker'
$helperArguments = @(
    '--headless', '--path', $projectRoot,
    '--log-file', (Join-Path $testRoot 'lost-ack-helper.log'),
    '--script', 'res://tests/g3_02/提交后失联助手.gd', '--',
    ('--db={0}' -f $lostAckDatabase), ('--marker={0}' -f $marker.Replace('\', '/'))
)
$helper = Start-Process -FilePath $godotExecutable -ArgumentList $helperArguments -WindowStyle Hidden -RedirectStandardOutput (Join-Path $testRoot 'helper.stdout.log') -RedirectStandardError (Join-Path $testRoot 'helper.stderr.log') -PassThru
$observed = $false
for ($attempt = 0; $attempt -lt 200; $attempt += 1) {
    if (Test-Path -LiteralPath $marker -PathType Leaf) { $observed = $true; break }
    if ($helper.HasExited) { break }
    Start-Sleep -Milliseconds 50
}
if (-not $observed) {
    if (-not $helper.HasExited) { $helper.Kill(); $helper.WaitForExit() }
    throw 'Helper did not reach the deterministic post-COMMIT marker.'
}
$actualExecutable = [IO.Path]::GetFullPath($helper.MainModule.FileName)
$expectedExecutable = [IO.Path]::GetFullPath($godotExecutable)
if (-not $actualExecutable.Equals($expectedExecutable, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Helper executable mismatch for PID $($helper.Id): $actualExecutable"
}
$terminatedPid = $helper.Id
$helper.Kill()
$helper.WaitForExit()
Write-Output "G3-02 EVIDENCE | terminated exact Godot PID $terminatedPid after COMMIT marker and before ACK"

Invoke-GodotScript -Script 'res://tests/g3_02/提交后重放验证.gd' -UserArguments @(('--db={0}' -f $lostAckDatabase)) -LogName 'lost-ack-replay.log'
Write-Output 'G3-02 PASS | production durable mutation harness completed'
