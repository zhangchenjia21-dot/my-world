[CmdletBinding()]
param(
    [switch]$SkipRealProvider
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName
$godotExecutable = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
$testRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_07_reality'))
if (-not $testRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase) -or
    (Split-Path -Leaf $testRoot) -ne 'g3_07_reality') {
    throw "Refusing unsafe G3-07 test path: $testRoot"
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

# 1. deterministic integrated reality path (Save/Load/Recover/recent-12/marker isolation)
Invoke-GodotScript -Script 'res://tests/g3_07/现实路径持久化测试.gd' -UserArguments @("--db=$slashRoot/reality.sqlite") -LogName 'reality.log'

# 2. DEC-05 central recovery button layout (3 resolutions + healthy/no-backup branches)
Invoke-GodotScript -Script 'res://tests/g3_07/灾难恢复界面布局测试.gd' -UserArguments @("--db=$slashRoot/ui_layout.sqlite") -LogName 'ui-layout.log' -WithWindow

# 3. adapted G3-06 disaster recovery UI regression
Invoke-GodotScript -Script 'res://tests/g3_06/灾难恢复界面测试.gd' -UserArguments @("--db=$slashRoot/g3_06_ui.sqlite") -LogName 'g3-06-ui.log'

# 4. real DeepSeek product continuity (blocking gate, limited transport retry inside)
if (-not $SkipRealProvider) {
    $providerValues = Read-LocalProviderEnvironment
    $previousKey = [Environment]::GetEnvironmentVariable('DEEPSEEK_API_KEY', 'Process')
    $previousModel = [Environment]::GetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', 'Process')
    try {
        [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', [string]$providerValues.DEEPSEEK_API_KEY, 'Process')
        if ($providerValues.ContainsKey('MY_WORLD_DEEPSEEK_MODEL')) { [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', [string]$providerValues.MY_WORLD_DEEPSEEK_MODEL, 'Process') }
        Invoke-GodotScript -Script 'res://tests/g3_07/真实续玩现实测试.gd' -UserArguments @("--db=$slashRoot/real.sqlite") -LogName 'real-provider.log' -WithWindow
    }
    finally {
        [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $previousKey, 'Process')
        [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', $previousModel, 'Process')
    }
}

Write-Output 'G3-07 PASS | reality validation harness completed'
