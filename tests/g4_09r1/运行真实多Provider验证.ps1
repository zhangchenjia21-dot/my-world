[CmdletBinding()]
param(
    [string]$Godot = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$envFile = Join-Path $projectRoot '.env.local'
$taskRoot = Join-Path $projectRoot 'build\g4_09r1\real-provider'
$evidence = Join-Path $taskRoot 'real-provider-results.json'
$allowed = @('DEEPSEEK_API_KEY', 'KIMI_API_KEY', 'MY_WORLD_DEEPSEEK_MODEL')
$values = @{}
if (Test-Path -LiteralPath $envFile -PathType Leaf) {
    foreach ($line in (Get-Content -LiteralPath $envFile)) {
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#')) { continue }
        $separator = $trimmed.IndexOf('=')
        if ($separator -le 0) { throw 'Invalid .env.local line; expected KEY=VALUE.' }
        $name = $trimmed.Substring(0, $separator).Trim()
        if ($allowed -notcontains $name) { throw "Unsupported .env.local variable: $name" }
        $values[$name] = $trimmed.Substring($separator + 1).Trim()
    }
}

$previous = @{}
foreach ($name in @('DEEPSEEK_API_KEY', 'KIMI_API_KEY')) {
    $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}
New-Item -ItemType Directory -Path $taskRoot -Force | Out-Null
try {
    foreach ($name in @('DEEPSEEK_API_KEY', 'KIMI_API_KEY')) {
        $value = if ($values.ContainsKey($name)) { [string]$values[$name] } else { '' }
        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
    $rootArg = $taskRoot.Replace('\', '/')
    $evidenceArg = $evidence.Replace('\', '/')
    & $Godot --headless --path $projectRoot --log-file (Join-Path $taskRoot 'godot.log') --script 'res://tests/g4_09r1/真实多Provider运行时验证.gd' -- "--root=$rootArg" "--evidence=$evidenceArg"
    exit $LASTEXITCODE
}
finally {
    foreach ($name in @('DEEPSEEK_API_KEY', 'KIMI_API_KEY')) {
        [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process')
    }
}
