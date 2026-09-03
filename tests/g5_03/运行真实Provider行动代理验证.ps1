[CmdletBinding()]
param(
    [string]$Godot = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe',
    [string]$Root = 'D:\AI\Projects\my-world\build\g503'
)

# 只把仓库 credential 白名单注入子进程；不打印、不复制、不持久化 secret value。
# Owner production settings/Source/Games/current DB 仅做前后 fingerprint，测试写入全部位于 $Root。
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$envFile = Join-Path $projectRoot '.env.local'
if (-not (Test-Path -LiteralPath $envFile -PathType Leaf)) { throw '.env.local is missing.' }

$allowed = @('DEEPSEEK_API_KEY', 'KIMI_API_KEY', 'MY_WORLD_DEEPSEEK_MODEL')
$values = @{}
foreach ($line in Get-Content -LiteralPath $envFile -Encoding UTF8) {
    $trimmed = $line.Trim()
    if ($trimmed.Length -eq 0 -or $trimmed.StartsWith('#')) { continue }
    $separator = $trimmed.IndexOf('=')
    if ($separator -le 0) { throw 'Invalid .env.local entry.' }
    $name = $trimmed.Substring(0, $separator).Trim()
    if ($allowed -notcontains $name) { throw "Unsupported .env.local variable: $name" }
    if ($values.ContainsKey($name)) { throw "Duplicate .env.local variable: $name" }
    $values[$name] = $trimmed.Substring($separator + 1).Trim()
}

function Get-PathFingerprint([string]$Path) {
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return @{ kind = 'file'; count = 1; sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant() }
    }
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return @{ kind = 'missing'; count = 0; sha256 = '' }
    }
    $files = @(Get-ChildItem -LiteralPath $Path -Recurse -File | Sort-Object FullName)
    $parts = @($files | ForEach-Object {
        $relative = $_.FullName.Substring($Path.Length).TrimStart('\')
        "$relative|$((Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash.ToLowerInvariant())"
    })
    $bytes = [Text.Encoding]::UTF8.GetBytes([string]::Join("`n", $parts))
    $sha = [Security.Cryptography.SHA256]::Create()
    return @{ kind = 'directory'; count = $files.Count; sha256 = ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant() }
}

function Get-OwnerSafetySnapshot {
    $ownerRoot = Join-Path $env:APPDATA 'Godot\app_userdata\my world\my-world'
    $result = [ordered]@{}
    foreach ($relative in @('settings\provider-runtime.json', 'source-library', 'games', 'game-library', 'current-game.sqlite')) {
        $result[$relative] = Get-PathFingerprint (Join-Path $ownerRoot $relative)
    }
    return $result
}

$previous = @{}
foreach ($name in $allowed) { $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }
New-Item -ItemType Directory -Path $Root -Force | Out-Null
$before = Get-OwnerSafetySnapshot
$beforePath = Join-Path $Root 'owner-safety-before.json'
$afterPath = Join-Path $Root 'owner-safety-after.json'
$evidencePath = Join-Path $Root 'world-turn-real.json'
$stateRoot = Join-Path $Root 'state'
$before | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $beforePath -Encoding UTF8

try {
    foreach ($name in $allowed) {
        $value = if ($values.ContainsKey($name)) { [string]$values[$name] } else { '' }
        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
    & $Godot --path $projectRoot --log-file (Join-Path $Root 'godot.log') --script 'res://tests/g5_03/真实Provider行动代理验证.gd' -- "--root=$($stateRoot.Replace('\', '/'))" "--evidence=$($evidencePath.Replace('\', '/'))"
    $exitCode = $LASTEXITCODE
}
finally {
    foreach ($name in $allowed) { [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process') }
    $after = Get-OwnerSafetySnapshot
    $after | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $afterPath -Encoding UTF8
}

if (($before | ConvertTo-Json -Depth 6 -Compress) -ne ($after | ConvertTo-Json -Depth 6 -Compress)) {
    throw 'Owner production settings/Source/Games/current DB fingerprint changed.'
}
if ($exitCode -ne 0) { throw "G5-03M1 real vertical failed with exit code $exitCode" }
Write-Host 'G5-03M1 REAL PROVIDER PASS | Owner production fingerprints unchanged.'
