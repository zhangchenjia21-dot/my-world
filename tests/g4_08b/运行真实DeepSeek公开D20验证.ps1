[CmdletBinding()]
param(
    [string]$Godot = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe',
    [string]$Root = 'D:\AI\Projects\my-world\build\g4_08b\real-vertical'
)

# G4-07B 真实 DeepSeek 可玩垂直运行器：允许共享 .env.local 同时保存 Kimi 凭据，
# 但本运行器只加载 DeepSeek 所需变量，绝不打印或转存其他凭据；结束后恢复原环境。
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$envFile = Join-Path $projectRoot '.env.local'
if (-not (Test-Path -LiteralPath $envFile -PathType Leaf)) { throw '.env.local is missing.' }

$values = @{}
$seenNames = @{}
foreach ($line in Get-Content -LiteralPath $envFile -Encoding UTF8) {
    $trimmed = $line.Trim()
    if ($trimmed.Length -eq 0 -or $trimmed.StartsWith('#')) { continue }
    $separator = $trimmed.IndexOf('=')
    if ($separator -le 0) { throw 'Invalid .env.local entry.' }
    $name = $trimmed.Substring(0, $separator).Trim()
    if (@('DEEPSEEK_API_KEY', 'MY_WORLD_DEEPSEEK_MODEL', 'KIMI_API_KEY') -notcontains $name) { throw "Unsupported .env.local variable: $name" }
    if ($seenNames.ContainsKey($name)) { throw "Duplicate .env.local variable: $name" }
    $seenNames[$name] = $true
    if ($name -eq 'KIMI_API_KEY') { continue }
    $values[$name] = $trimmed.Substring($separator + 1).Trim()
}
if (-not $values.ContainsKey('DEEPSEEK_API_KEY') -or [string]::IsNullOrWhiteSpace([string]$values.DEEPSEEK_API_KEY)) { throw 'DEEPSEEK_API_KEY is missing.' }

$previousKey = [Environment]::GetEnvironmentVariable('DEEPSEEK_API_KEY', 'Process')
$previousModel = [Environment]::GetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', 'Process')
try {
    [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', [string]$values.DEEPSEEK_API_KEY, 'Process')
    if ($values.ContainsKey('MY_WORLD_DEEPSEEK_MODEL')) {
        [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', [string]$values.MY_WORLD_DEEPSEEK_MODEL, 'Process')
    }
    $evidence = Join-Path $Root 'real-vertical-evidence.json'
    $shots = Join-Path $Root 'shots'
    & $Godot --path $projectRoot --script 'res://tests/g4_08b/真实公开D20界面垂直测试.gd' -- "--root=$($Root.Replace('\', '/'))" "--shot-dir=$($shots.Replace('\', '/'))" "--evidence=$($evidence.Replace('\', '/'))"
    if ($LASTEXITCODE -ne 0) { throw "G4-08B real public d20 vertical failed with exit code $LASTEXITCODE" }
}
finally {
    [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $previousKey, 'Process')
    [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', $previousModel, 'Process')
}
