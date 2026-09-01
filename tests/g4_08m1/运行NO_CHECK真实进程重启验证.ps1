[CmdletBinding()]
param(
    [string]$Godot = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe',
    [string]$Root = 'D:\AI\Projects\my-world\build\g4_08m1\no-check-process-restart'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$taskRoot = [System.IO.Path]::GetFullPath($Root)
$projectBuild = [System.IO.Path]::GetFullPath((Join-Path $projectRoot 'build'))
if (-not $taskRoot.StartsWith($projectBuild + '\', [System.StringComparison]::OrdinalIgnoreCase) -or $taskRoot -notmatch 'g4_08m1') {
    throw 'Root must be a task-owned g4_08m1 directory under repository build.'
}
$caseRoot = Join-Path $taskRoot 'case'
$proofRoot = Join-Path $taskRoot 'proofs'
$logRoot = Join-Path $taskRoot 'logs'
New-Item -ItemType Directory -Force -Path $caseRoot, $proofRoot, $logRoot | Out-Null

function Invoke-Phase {
    param([string]$Phase, [string]$Proof, [string]$PriorProof = '')
    $arguments = @(
        '--headless', '--path', $projectRoot,
        '--log-file', (Join-Path $logRoot "$Phase.log"),
        '--script', 'res://tests/g4_08m1/NO_CHECK真实进程重启阶段.gd', '--',
        "--phase=$Phase", "--case-root=$($caseRoot.Replace('\', '/'))", "--proof=$($Proof.Replace('\', '/'))"
    )
    if (-not [string]::IsNullOrWhiteSpace($PriorProof)) { $arguments += "--prior-proof=$($PriorProof.Replace('\', '/'))" }
    & $Godot @arguments
    if ($LASTEXITCODE -ne 0) { throw "G4-08M1C01 process phase failed: $Phase exit=$LASTEXITCODE" }
    if (-not (Test-Path -LiteralPath $Proof -PathType Leaf)) { throw "Missing phase proof: $Proof" }
}

$aPath = Join-Path $proofRoot 'process-a.json'
$bPath = Join-Path $proofRoot 'process-b.json'
Invoke-Phase -Phase 'accept' -Proof $aPath
$databasePath = ([string](Get-Content -LiteralPath $aPath -Raw | ConvertFrom-Json).database_path).Replace('/', '\')
$hashBeforeReplay = (Get-FileHash -LiteralPath $databasePath -Algorithm SHA256).Hash
Invoke-Phase -Phase 'replay' -Proof $bPath -PriorProof $aPath
$hashAfterReplay = (Get-FileHash -LiteralPath $databasePath -Algorithm SHA256).Hash

$a = Get-Content -LiteralPath $aPath -Raw | ConvertFrom-Json
$b = Get-Content -LiteralPath $bPath -Raw | ConvertFrom-Json
if ($a.pid -eq $b.pid) { throw 'Expected distinct Godot process IDs.' }
if ($a.game_id -ne $b.game_id -or $a.resolution_id -ne $b.resolution_id) { throw 'Game or NO_CHECK replay identity changed across process restart.' }
if ($a.accepted_count -ne 1 -or $b.accepted_count -ne 1) { throw 'Accepted Conversation duplicated across process replay.' }
if ($hashBeforeReplay -ne $hashAfterReplay) { throw 'Accepted NO_CHECK replay mutated the Game database.' }

Write-Output "G4-08M1C01 REAL PROCESS RESTART PASS | PIDs=$($a.pid),$($b.pid) game=$($a.game_id) resolution=$($a.resolution_id)"
