[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$output = Join-Path $projectRoot 'build/mw025/real'
if (Test-Path -LiteralPath $output) { throw 'Use fresh real attempt; no retry.' }
New-Item -ItemType Directory $output | Out-Null

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
    & 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path $projectRoot --script 'res://tests/mw025/真实角色推荐验证.gd' -- ('--root=' + $output.Replace('\','/')) *> (Join-Path $projectRoot 'build/mw025/real-provider.log')
    $result = $LASTEXITCODE
}
finally {
    foreach ($name in $allowed) { [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process') }
}
exit $result
