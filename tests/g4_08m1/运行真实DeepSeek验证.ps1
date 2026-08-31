[CmdletBinding()]
param(
    [string]$Godot = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe',
    [string]$Root = 'D:\AI\Projects\my-world\build\g4_08m1_real_provider'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$envFile = Join-Path $projectRoot '.env.local'
if (-not (Test-Path -LiteralPath $envFile -PathType Leaf)) { throw '.env.local is missing.' }

$values = @{}
foreach ($line in Get-Content -LiteralPath $envFile -Encoding UTF8) {
    $trimmed = $line.Trim()
    if ($trimmed.Length -eq 0 -or $trimmed.StartsWith('#')) { continue }
    $separator = $trimmed.IndexOf('=')
    if ($separator -le 0) { throw 'Invalid .env.local entry.' }
    $name = $trimmed.Substring(0, $separator).Trim()
    if (@('DEEPSEEK_API_KEY', 'MY_WORLD_DEEPSEEK_MODEL') -notcontains $name) { throw "Unsupported .env.local variable: $name" }
    if ($values.ContainsKey($name)) { throw "Duplicate .env.local variable: $name" }
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
    $evidence = Join-Path $Root 'real-provider-evidence.json'
    & $Godot --headless --path $projectRoot --log-file (Join-Path $Root 'godot.log') --script 'res://tests/g4_08m1/真实DeepSeek公开D20测试.gd' -- "--root=$($Root.Replace('\', '/'))" "--evidence=$($evidence.Replace('\', '/'))"
    if ($LASTEXITCODE -ne 0) { throw "G4-08M1 real Provider validation failed with exit code $LASTEXITCODE" }
}
finally {
    [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $previousKey, 'Process')
    [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', $previousModel, 'Process')
}
