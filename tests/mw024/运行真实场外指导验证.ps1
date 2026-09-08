[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$output = Join-Path $projectRoot 'build/mw024/real-ooc.json'
if (Test-Path -LiteralPath $output) { throw 'Real attempt already recorded; do not retry.' }
$allowed = @('KIMI_API_KEY', 'DEEPSEEK_API_KEY')
$previous = @{}
foreach ($name in $allowed) { $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }
try {
    # Only inject the existing credential allowlist; never print or persist values.
    foreach ($line in Get-Content -LiteralPath 'D:/AI/Projects/my-world/.env.local') {
        $parts = $line.Split('=', 2)
        if ($parts.Count -eq 2 -and $allowed -contains $parts[0].Trim()) {
            [Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), 'Process')
        }
    }
    & 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path $projectRoot --script 'res://tests/mw024/真实场外指导验证.gd' -- ('--output=' + $output.Replace('\','/')) *> (Join-Path $projectRoot 'build/mw024/real-ooc.log')
    $result = $LASTEXITCODE
}
finally {
    foreach ($name in $allowed) { [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process') }
}
exit $result
