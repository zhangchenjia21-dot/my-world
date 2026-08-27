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
$testRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_03_test'))
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_03_test'))

if (-not (Test-Path -LiteralPath $godotExecutable -PathType Leaf)) { throw "Godot executable not found: $godotExecutable" }
if (-not $testRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    -not $testRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase) -or
    (Split-Path -Leaf $testRoot) -ne 'g3_03_test') {
    throw "Refusing unsafe G3-03 test path: $testRoot"
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
        if ($values.ContainsKey($name)) { throw "Duplicate .env.local variable: $name" }
        $values[$name] = $trimmed.Substring($separator + 1).Trim()
    }
    if (-not $values.ContainsKey('DEEPSEEK_API_KEY') -or [string]::IsNullOrWhiteSpace([string]$values.DEEPSEEK_API_KEY)) {
        throw 'DEEPSEEK_API_KEY is missing.'
    }
    return $values
}

function Invoke-RunGameSmoke {
    param([Parameter(Mandatory = $true)][string]$DatabasePath)
    $launcher = Join-Path $projectRoot 'run-game.ps1'
    $expectedGame = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\windows\my-world.exe'))
    $baselineIds = @{}
    foreach ($existing in Get-Process) {
        try {
            if ([IO.Path]::GetFullPath($existing.MainModule.FileName).Equals($expectedGame, [StringComparison]::OrdinalIgnoreCase)) {
                $baselineIds[$existing.Id] = $true
            }
        }
        catch {}
    }
    $process = Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $launcher) -WindowStyle Hidden -PassThru
    $gameProcess = $null
    for ($attempt = 0; $attempt -lt 200; $attempt += 1) {
        foreach ($candidate in Get-Process) {
            try {
                $candidatePath = [IO.Path]::GetFullPath($candidate.MainModule.FileName)
                if (-not $baselineIds.ContainsKey($candidate.Id) -and
                    $candidatePath.Equals($expectedGame, [StringComparison]::OrdinalIgnoreCase)) {
                    $gameProcess = $candidate
                    break
                }
            }
            catch {}
        }
        if ($null -ne $gameProcess -or $process.HasExited) { break }
        Start-Sleep -Milliseconds 50
    }
    if ($null -eq $gameProcess) {
        if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
        throw 'run-game.ps1 did not start the exact exported product executable.'
    }
    $actualGame = [IO.Path]::GetFullPath($gameProcess.MainModule.FileName)
    if (-not $actualGame.Equals($expectedGame, [StringComparison]::OrdinalIgnoreCase)) {
        throw "run-game child identity mismatch for PID $($gameProcess.Id): $actualGame"
    }
    for ($attempt = 0; $attempt -lt 200; $attempt += 1) {
        if (Test-Path -LiteralPath $DatabasePath -PathType Leaf) { break }
        if ($gameProcess.HasExited) { break }
        Start-Sleep -Milliseconds 50
    }
    if (-not (Test-Path -LiteralPath $DatabasePath -PathType Leaf)) { throw 'normal product did not create/open isolated Current Game DB.' }
    # 文件句柄出现早于 first-run initial Game transaction COMMIT；留出明确启动窗口后再做
    # exact-PID smoke termination，避免把“DB file created”误当成“Game creation committed”。
    Start-Sleep -Milliseconds 1500
    if ($gameProcess.HasExited) { throw 'exported product exited before Current Game startup stabilized.' }
    $exactPid = $gameProcess.Id
    $gameProcess.Kill()
    $gameProcess.WaitForExit()
    if (-not $process.HasExited) { $process.WaitForExit(10000) | Out-Null }
    Write-Output "G3-03 PRODUCT SMOKE | exact executable/PID verified and stopped: $exactPid"
}

$slashRoot = $testRoot.Replace('\', '/')
Invoke-GodotScript -Script 'res://tests/g3_03/会话恢复与候选测试.gd' -UserArguments @() -LogName 'domain.log'
Invoke-GodotScript -Script 'res://tests/g3_03/持久化迁移与生命周期测试.gd' -UserArguments @(('--root={0}' -f $slashRoot)) -LogName 'lifecycle.log'

$processDatabase = (Join-Path $testRoot 'two-process.sqlite').Replace('\', '/')
$processProof = (Join-Path $testRoot 'two-process.json').Replace('\', '/')
Invoke-GodotScript -Script 'res://tests/g3_03/跨进程恢复助手.gd' -UserArguments @('--mode=seed', ('--db={0}' -f $processDatabase), ('--proof={0}' -f $processProof)) -LogName 'process-a.log'
Invoke-GodotScript -Script 'res://tests/g3_03/跨进程恢复助手.gd' -UserArguments @('--mode=continue', ('--db={0}' -f $processDatabase), ('--proof={0}' -f $processProof)) -LogName 'process-b.log'
Invoke-GodotScript -Script 'res://tests/g3_03/跨进程恢复助手.gd' -UserArguments @('--mode=verify-four', ('--db={0}' -f $processDatabase), ('--proof={0}' -f $processProof)) -LogName 'process-verify.log'
Invoke-GodotScript -Script 'res://tests/g3_03/上下文恢复与界面测试.gd' -UserArguments @(('--root={0}' -f $slashRoot)) -LogName 'context-ui.log'

if (-not $SkipRegressions) {
    & (Join-Path $projectRoot 'tests\g3_02\运行真实验证.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'G3-02 regression harness failed.' }
    & (Join-Path $projectRoot 'tests\g3_01\运行真实验证.ps1') -SkipExport
    if ($LASTEXITCODE -ne 0) { throw 'G3-01 regression harness failed.' }
    Invoke-GodotScript -Script 'res://tests/g2_05_上下文组装离线测试.gd' -UserArguments @() -LogName 'g2-05.log'
    Invoke-GodotScript -Script 'res://tests/g2_04_会话域离线测试.gd' -UserArguments @() -LogName 'g2-04.log'
    Invoke-GodotScript -Script 'res://tests/g2_03_会话视图离线测试.gd' -UserArguments @() -LogName 'g2-03.log'
}

if (-not $SkipRealProvider) {
    $providerValues = Read-LocalProviderEnvironment
    $previousKey = [Environment]::GetEnvironmentVariable('DEEPSEEK_API_KEY', 'Process')
    $previousModel = [Environment]::GetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', 'Process')
    try {
        [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', [string]$providerValues.DEEPSEEK_API_KEY, 'Process')
        if ($providerValues.ContainsKey('MY_WORLD_DEEPSEEK_MODEL')) {
            [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', [string]$providerValues.MY_WORLD_DEEPSEEK_MODEL, 'Process')
        }
        $realDatabase = (Join-Path $testRoot 'real-resume.sqlite').Replace('\', '/')
        $realProof = (Join-Path $testRoot 'real-resume.json').Replace('\', '/')
        Invoke-GodotScript -Script 'res://tests/g3_03/跨进程恢复助手.gd' -UserArguments @('--mode=seed', ('--db={0}' -f $realDatabase), ('--proof={0}' -f $realProof)) -LogName 'real-seed.log'
        Invoke-GodotScript -Script 'res://tests/g3_03/真实续玩界面测试.gd' -UserArguments @(('--db={0}' -f $realDatabase), ('--proof={0}' -f $realProof)) -LogName 'real-gui.log' -WithWindow
        Invoke-GodotScript -Script 'res://tests/g3_03/跨进程恢复助手.gd' -UserArguments @('--mode=verify-four', ('--db={0}' -f $realDatabase), ('--proof={0}' -f $realProof)) -LogName 'real-reopen.log'
    }
    finally {
        [Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', $previousKey, 'Process')
        [Environment]::SetEnvironmentVariable('MY_WORLD_DEEPSEEK_MODEL', $previousModel, 'Process')
    }
}

if (-not $SkipExport) {
    $windowsDirectory = Join-Path $projectRoot 'build\windows'
    New-Item -ItemType Directory -Force -Path $windowsDirectory | Out-Null
    $exportExecutable = Join-Path $windowsDirectory 'my-world.exe'
    & $godotExecutable --headless --path $projectRoot --log-file (Join-Path $testRoot 'export.log') --export-debug 'Windows Desktop' $exportExecutable
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $exportExecutable -PathType Leaf)) { throw 'Windows Desktop export failed.' }

    $productDatabase = Join-Path $testRoot 'normal-product.sqlite'
    $productProof = (Join-Path $testRoot 'normal-product.json').Replace('\', '/')
    $previousOverride = [Environment]::GetEnvironmentVariable('MY_WORLD_TEST_CURRENT_GAME_DB', 'Process')
    try {
        [Environment]::SetEnvironmentVariable('MY_WORLD_TEST_CURRENT_GAME_DB', $productDatabase, 'Process')
        Invoke-RunGameSmoke -DatabasePath $productDatabase
        Invoke-GodotScript -Script 'res://tests/g3_03/跨进程恢复助手.gd' -UserArguments @('--mode=capture-zero', ('--db={0}' -f $productDatabase.Replace('\', '/')), ('--proof={0}' -f $productProof)) -LogName 'product-first.log'
        Invoke-RunGameSmoke -DatabasePath $productDatabase
        Invoke-GodotScript -Script 'res://tests/g3_03/跨进程恢复助手.gd' -UserArguments @('--mode=verify-zero', ('--db={0}' -f $productDatabase.Replace('\', '/')), ('--proof={0}' -f $productProof)) -LogName 'product-reopen.log'
    }
    finally {
        [Environment]::SetEnvironmentVariable('MY_WORLD_TEST_CURRENT_GAME_DB', $previousOverride, 'Process')
    }
}

Write-Output 'G3-03 PASS | full Game reopen/resume validation harness completed'
