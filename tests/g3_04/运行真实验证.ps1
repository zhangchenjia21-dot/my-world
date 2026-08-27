[CmdletBinding()]
param(
    [switch]$SkipRealProvider,
    [switch]$SkipExport,
    [switch]$SkipRegressions
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName
$godotExecutable = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
$testRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_04_test'))
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_04_test'))
if (-not (Test-Path -LiteralPath $godotExecutable -PathType Leaf)) { throw "Godot executable not found: $godotExecutable" }
if (-not $testRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    -not $testRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase) -or
    (Split-Path -Leaf $testRoot) -ne 'g3_04_test') {
    throw "Refusing unsafe G3-04 test path: $testRoot"
}
if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
New-Item -ItemType Directory -Path $testRoot | Out-Null

function Invoke-GodotScript {
    param(
        [Parameter(Mandatory = $true)][string]$Script,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$UserArguments,
        [Parameter(Mandatory = $true)][string]$LogName,
        [switch]$WithWindow
    )
    $arguments = @()
    if (-not $WithWindow) { $arguments += '--headless' }
    $arguments += @('--path', $projectRoot, '--log-file', (Join-Path $testRoot $LogName), '--script', $Script, '--')
    $arguments += $UserArguments
    & $godotExecutable @arguments
    if ($LASTEXITCODE -ne 0) { throw "Godot script failed ($LASTEXITCODE): $Script" }
}

function Read-LocalProviderEnvironment {
    $envFile = Join-Path $projectRoot '.env.local'
    if (-not (Test-Path -LiteralPath $envFile -PathType Leaf)) { throw "Missing local Provider environment file: $envFile" }
    $values = @{}
    foreach ($line in (Get-Content -LiteralPath $envFile)) {
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#')) { continue }
        $separator = $trimmed.IndexOf('=')
        if ($separator -le 0) { throw 'Invalid .env.local entry.' }
        $name = $trimmed.Substring(0, $separator).Trim()
        if (@('DEEPSEEK_API_KEY', 'MY_WORLD_DEEPSEEK_MODEL') -notcontains $name) { throw "Unsupported .env.local variable: $name" }
        $values[$name] = $trimmed.Substring($separator + 1).Trim()
    }
    if (-not $values.ContainsKey('DEEPSEEK_API_KEY') -or [string]::IsNullOrWhiteSpace([string]$values.DEEPSEEK_API_KEY)) { throw 'DEEPSEEK_API_KEY is missing.' }
    return $values
}

function Invoke-RunGameSmoke {
    param([Parameter(Mandatory = $true)][string]$DatabasePath)
    $launcher = Join-Path $projectRoot 'run-game.ps1'
    $expectedGame = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\windows\my-world.exe'))
    $baselineIds = @{}
    foreach ($existing in Get-Process) {
        try {
            if ([IO.Path]::GetFullPath($existing.MainModule.FileName).Equals($expectedGame, [StringComparison]::OrdinalIgnoreCase)) { $baselineIds[$existing.Id] = $true }
        }
        catch {}
    }
    $launcherProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $launcher) -WindowStyle Hidden -PassThru
    $gameProcess = $null
    for ($attempt = 0; $attempt -lt 200; $attempt += 1) {
        foreach ($candidate in Get-Process) {
            try {
                $candidatePath = [IO.Path]::GetFullPath($candidate.MainModule.FileName)
                if (-not $baselineIds.ContainsKey($candidate.Id) -and $candidatePath.Equals($expectedGame, [StringComparison]::OrdinalIgnoreCase)) { $gameProcess = $candidate; break }
            }
            catch {}
        }
        if ($null -ne $gameProcess -or $launcherProcess.HasExited) { break }
        Start-Sleep -Milliseconds 50
    }
    if ($null -eq $gameProcess) {
        if (-not $launcherProcess.HasExited) { $launcherProcess.Kill(); $launcherProcess.WaitForExit() }
        throw 'run-game.ps1 did not start the exact exported product executable.'
    }
    for ($attempt = 0; $attempt -lt 200; $attempt += 1) {
        if (Test-Path -LiteralPath $DatabasePath -PathType Leaf) { break }
        if ($gameProcess.HasExited) { break }
        Start-Sleep -Milliseconds 50
    }
    if (-not (Test-Path -LiteralPath $DatabasePath -PathType Leaf)) { throw 'exported product did not open isolated Current Game DB.' }
    Start-Sleep -Milliseconds 1500
    if ($gameProcess.HasExited) { throw 'exported product exited before startup stabilized.' }
    $exactPid = $gameProcess.Id
    $gameProcess.Kill(); $gameProcess.WaitForExit()
    if (-not $launcherProcess.HasExited) { $launcherProcess.WaitForExit(10000) | Out-Null }
    Write-Output "G3-04 PRODUCT SMOKE | exact exported executable/PID verified and stopped: $exactPid"
}

$slashRoot = $testRoot.Replace('\', '/')
Invoke-GodotScript -Script 'res://tests/g3_04/会话恢复验证测试.gd' -UserArguments @() -LogName 'domain.log'
Invoke-GodotScript -Script 'res://tests/g3_04/存档恢复持久化测试.gd' -UserArguments @("--root=$slashRoot") -LogName 'persistence.log'
Invoke-GodotScript -Script 'res://tests/g3_04/存档读取界面测试.gd' -UserArguments @("--db=$slashRoot/ui.sqlite") -LogName 'ui.log'
& (Join-Path $PSScriptRoot '运行崩溃恢复验证.ps1')
if ($LASTEXITCODE -ne 0) { throw 'G3-04 crash harness failed.' }

if (-not $SkipRegressions) {
    & (Join-Path $projectRoot 'tests\g3_03\运行真实验证.ps1') -SkipRealProvider -SkipExport
    if ($LASTEXITCODE -ne 0) { throw 'G3-03/G3-02/G3-01/G2 regression harness failed.' }
}

if (-not $SkipRealProvider) {
    $providerValues = Read-LocalProviderEnvironment
    $previousKey = [Environment]::GetEnvironmentVariable('DEEPSEEK_API_KEY', 'Process')
    $previousModel = [Environment]::GetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', 'Process')
    try {
        [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', [string]$providerValues.DEEPSEEK_API_KEY, 'Process')
        if ($providerValues.ContainsKey('MY_WORLD_DEEPSEEK_MODEL')) { [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', [string]$providerValues.MY_WORLD_DEEPSEEK_MODEL, 'Process') }
        Invoke-GodotScript -Script 'res://tests/g3_04/真实读取续玩界面测试.gd' -UserArguments @("--db=$slashRoot/real-provider.sqlite") -LogName 'real-provider.log' -WithWindow
    }
    finally {
        [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $previousKey, 'Process')
        [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', $previousModel, 'Process')
    }
}

if (-not $SkipExport) {
    $windowsDirectory = Join-Path $projectRoot 'build\windows'
    New-Item -ItemType Directory -Force -Path $windowsDirectory | Out-Null
    $exportExecutable = Join-Path $windowsDirectory 'my-world.exe'
    & $godotExecutable --headless --path $projectRoot --log-file (Join-Path $testRoot 'export.log') --export-debug 'Windows Desktop' $exportExecutable
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $exportExecutable -PathType Leaf)) { throw 'Windows Desktop export failed.' }
    $productDatabase = Join-Path $testRoot 'normal-product.sqlite'
    $previousOverride = [Environment]::GetEnvironmentVariable('MY_WORLD_TEST_CURRENT_GAME_DB', 'Process')
    try {
        [Environment]::SetEnvironmentVariable('MY_WORLD_TEST_CURRENT_GAME_DB', $productDatabase, 'Process')
        Invoke-RunGameSmoke -DatabasePath $productDatabase
        Invoke-RunGameSmoke -DatabasePath $productDatabase
    }
    finally {
        [Environment]::SetEnvironmentVariable('MY_WORLD_TEST_CURRENT_GAME_DB', $previousOverride, 'Process')
    }
}

Write-Output 'G3-04 PASS | full explicit Save/Load/Restore validation harness completed'
