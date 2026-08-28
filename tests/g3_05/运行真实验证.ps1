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
$testRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_05_test'))
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_05_test'))
if (-not $testRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    -not $testRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase) -or
    (Split-Path -Leaf $testRoot) -ne 'g3_05_test') {
    throw "Refusing unsafe G3-05 test path: $testRoot"
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

$slashRoot = $testRoot.Replace('\', '/')
Invoke-GodotScript -Script 'res://tests/g3_05/恢复时间线持久化测试.gd' -UserArguments @("--root=$slashRoot") -LogName 'persistence.log'
Invoke-GodotScript -Script 'res://tests/g3_05/恢复进度界面测试.gd' -UserArguments @("--db=$slashRoot/ui.sqlite") -LogName 'ui.log'
& (Join-Path $PSScriptRoot '运行崩溃恢复验证.ps1')
if ($LASTEXITCODE -ne 0) { throw 'G3-05 crash harness failed.' }

if (-not $SkipRegressions) {
    & (Join-Path $projectRoot 'tests\g3_04\运行真实验证.ps1') -SkipRealProvider -SkipExport
    if ($LASTEXITCODE -ne 0) { throw 'G3-04/G3-03/G3-02/G3-01/G2 regression harness failed.' }
}

if (-not $SkipRealProvider) {
    $providerValues = Read-LocalProviderEnvironment
    $previousKey = [Environment]::GetEnvironmentVariable('DEEPSEEK_API_KEY', 'Process')
    $previousModel = [Environment]::GetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', 'Process')
    try {
        [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', [string]$providerValues.DEEPSEEK_API_KEY, 'Process')
        if ($providerValues.ContainsKey('MY_WORLD_DEEPSEEK_MODEL')) { [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', [string]$providerValues.MY_WORLD_DEEPSEEK_MODEL, 'Process') }
        Invoke-GodotScript -Script 'res://tests/g3_05/真实恢复续玩界面测试.gd' -UserArguments @("--db=$slashRoot/real-provider.sqlite") -LogName 'real-provider.log' -WithWindow
    }
    finally {
        [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $previousKey, 'Process')
        [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', $previousModel, 'Process')
    }
}

if (-not $SkipExport) {
    # 复用 G3-04 已审计的 Windows export 与 run-game.ps1 exact executable/PID smoke。
    & (Join-Path $projectRoot 'tests\g3_04\运行真实验证.ps1') -SkipRealProvider -SkipRegressions
    if ($LASTEXITCODE -ne 0) { throw 'Windows export/run-game smoke failed.' }
}

Write-Output 'G3-05 PASS | full Recovery / Timeline Foundation validation harness completed'
