param(
    [string]$TestRoot = 'D:\AI\Projects\my-world\build\g4_06_ir01_process_restart'
)

$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath('D:\AI\Projects\my-world')
$godot = [IO.Path]::GetFullPath('D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe')
$phaseScript = 'res://tests/g4_06/真实进程重启阶段.gd'
$resolvedTestRoot = [IO.Path]::GetFullPath($TestRoot)
$allowedBuildRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build')) + [IO.Path]::DirectorySeparatorChar

if (-not $resolvedTestRoot.StartsWith($allowedBuildRoot, [StringComparison]::OrdinalIgnoreCase) -or
    $resolvedTestRoot.IndexOf('g4_06', [StringComparison]::OrdinalIgnoreCase) -lt 0) {
    throw "Refusing non-task-owned TestRoot: $resolvedTestRoot"
}
if (Test-Path -LiteralPath $resolvedTestRoot) {
    Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $resolvedTestRoot -Force | Out-Null

$providerReferences = Get-ChildItem -LiteralPath (Join-Path $projectRoot 'src\最终建局') -Recurse -Filter '*.gd' |
    Select-String -Pattern 'provider|AI Opening|opening prose' -CaseSensitive:$false
if ($providerReferences) {
    throw 'Final Create production module unexpectedly references Provider/AI Opening.'
}

$faults = @(
    'after_intent_publish',
    'after_database_commit',
    'after_library_record_publish',
    'after_current_publish'
)

function Invoke-Phase {
    param(
        [string]$Fault,
        [string]$Phase,
        [string]$CaseRoot,
        [string]$ProofPath
    )

    $logPath = Join-Path $CaseRoot "$Phase.godot.log"
    New-Item -ItemType Directory -Path $CaseRoot -Force | Out-Null
    & $godot --headless --path $projectRoot --log-file $logPath --script $phaseScript -- `
        "--phase=$Phase" "--fault=$Fault" "--case-root=$($CaseRoot.Replace('\', '/'))" "--proof=$($ProofPath.Replace('\', '/'))"
    if ($LASTEXITCODE -ne 0) {
        throw "Godot phase failed: fault=$Fault phase=$Phase exit=$LASTEXITCODE log=$logPath"
    }
    if (-not (Test-Path -LiteralPath $ProofPath)) {
        throw "Missing phase proof: $ProofPath"
    }
    return Get-Content -LiteralPath $ProofPath -Raw -Encoding UTF8 | ConvertFrom-Json
}

foreach ($fault in $faults) {
    $caseRoot = Join-Path $resolvedTestRoot $fault
    $proofRoot = Join-Path $caseRoot 'proofs'
    $faultProofPath = Join-Path $proofRoot 'process-a.json'
    $resumeProofPath = Join-Path $proofRoot 'process-b.json'
    $replayProofPath = Join-Path $proofRoot 'process-c.json'

    $processA = Invoke-Phase -Fault $fault -Phase 'fault' -CaseRoot $caseRoot -ProofPath $faultProofPath
    $processB = Invoke-Phase -Fault $fault -Phase 'resume' -CaseRoot $caseRoot -ProofPath $resumeProofPath
    $processC = Invoke-Phase -Fault $fault -Phase 'replay' -CaseRoot $caseRoot -ProofPath $replayProofPath

    if ($processA.process_id -eq $processB.process_id -or $processA.process_id -eq $processC.process_id -or $processB.process_id -eq $processC.process_id) {
        throw "$fault did not cross three distinct OS process IDs"
    }
    foreach ($field in @('game_id', 'root_node_id', 'local_player_id')) {
        if ($processA.$field -ne $processB.$field -or $processA.$field -ne $processC.$field) {
            throw "$fault fixed identity mismatch: $field"
        }
    }
    if (($processA.local_npc_ids | ConvertTo-Json -Compress) -ne ($processB.local_npc_ids | ConvertTo-Json -Compress) -or
        ($processA.local_npc_ids | ConvertTo-Json -Compress) -ne ($processC.local_npc_ids | ConvertTo-Json -Compress)) {
        throw "$fault fixed local NPC identities mismatch"
    }
    if ($processB.db_count -ne 1 -or $processC.db_count -ne 1 -or
        $processB.record_count -ne 1 -or $processC.record_count -ne 1 -or
        $processB.inventory_count -ne 1 -or $processC.inventory_count -ne 1 -or
        -not $processB.current_matches -or -not $processC.current_matches) {
        throw "$fault did not converge to exactly one DB/record/current"
    }
    if (-not $processB.root_matches -or -not $processC.root_matches -or
        $processB.accepted_count -ne 0 -or $processC.accepted_count -ne 0 -or
        $processB.ai_opening_turns -ne 0 -or $processC.ai_opening_turns -ne 0) {
        throw "$fault root/Conversation/no-Provider proof failed"
    }
    if ($processB.database_sha256 -ne $processC.database_sha256) {
        throw "$fault exact replay changed/replaced valid DB bytes"
    }

    switch ($fault) {
        'after_intent_publish' {
            if ($processA.db_count -ne 0 -or $processA.record_count -ne 0 -or $processA.current_matches) {
                throw 'after_intent_publish durable window shape mismatch'
            }
        }
        'after_database_commit' {
            if ($processA.db_count -ne 1 -or $processA.record_count -ne 0 -or $processA.current_matches) {
                throw 'after_database_commit durable window shape mismatch'
            }
            if ($processA.database_sha256 -ne $processB.database_sha256) {
                throw 'after_database_commit retry changed/replaced valid DB bytes'
            }
        }
        'after_library_record_publish' {
            if ($processA.db_count -ne 1 -or $processA.record_count -ne 1 -or $processA.current_matches) {
                throw 'after_library_record_publish durable window shape mismatch'
            }
            if ($processA.database_sha256 -ne $processB.database_sha256) {
                throw 'after_library_record_publish retry changed/replaced valid DB bytes'
            }
        }
        'after_current_publish' {
            if ($processA.db_count -ne 1 -or $processA.record_count -ne 1 -or -not $processA.current_matches) {
                throw 'after_current_publish durable window shape mismatch'
            }
            if ($processA.database_sha256 -ne $processB.database_sha256) {
                throw 'after_current_publish retry changed/replaced valid DB bytes'
            }
        }
    }

    Write-Output "G4-06 IR01 PROCESS PASS | $fault | pidA=$($processA.process_id) pidB=$($processB.process_id) pidC=$($processC.process_id) | game=$($processA.game_id)"
}

Write-Output 'G4-06 IR01 PROCESS | done failures=0'
