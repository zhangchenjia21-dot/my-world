[CmdletBinding()]
param(
    [switch]$SkipExport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName
$godotExecutable = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
$testRoot = Join-Path $projectRoot 'build\g3_01_test'
$expectedTestRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_01_test'))

if (-not (Test-Path -LiteralPath $godotExecutable -PathType Leaf)) {
    throw "Godot 4.7.2 console executable not found: $godotExecutable"
}
if ([IO.Path]::GetFullPath($testRoot) -ne $expectedTestRoot -or
    -not $expectedTestRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing unsafe G3-01 test path: $testRoot"
}

# 清理只针对上面精确验证过的 build/g3_01_test；不扫描或猜测 user:// / 玩家数据库。
if (Test-Path -LiteralPath $expectedTestRoot) {
    Remove-Item -LiteralPath $expectedTestRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $expectedTestRoot | Out-Null

function Invoke-GodotScript {
    param(
        [Parameter(Mandatory = $true)][string]$Script,
        [Parameter(Mandatory = $true)][string[]]$UserArguments,
        [Parameter(Mandatory = $true)][string]$LogName
    )

    $logPath = Join-Path $expectedTestRoot $LogName
    & $godotExecutable --headless --path $projectRoot --log-file $logPath --script $Script -- @UserArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Godot script failed ($LASTEXITCODE): $Script"
    }
}

$slashTestRoot = $expectedTestRoot.Replace('\', '/')
Invoke-GodotScript `
    -Script 'res://tests/g3_01/持久化离线测试.gd' `
    -UserArguments @(('--root={0}' -f $slashTestRoot)) `
    -LogName 'offline.log'

$crashDatabase = (Join-Path $expectedTestRoot 'crash.sqlite').Replace('\', '/')
$readyFile = Join-Path $expectedTestRoot 'pre_commit.ready'
$helperStdout = Join-Path $expectedTestRoot 'crash-helper.stdout.log'
$helperStderr = Join-Path $expectedTestRoot 'crash-helper.stderr.log'
$helperLog = (Join-Path $expectedTestRoot 'crash-helper.godot.log').Replace('\', '/')
$helperArguments = @(
    '--headless',
    '--path', $projectRoot,
    '--log-file', $helperLog,
    '--script', 'res://tests/g3_01/未提交写入助手.gd',
    '--',
    ('--db={0}' -f $crashDatabase),
    ('--ready={0}' -f $readyFile.Replace('\', '/'))
)

$helperProcess = Start-Process `
    -FilePath $godotExecutable `
    -ArgumentList $helperArguments `
    -WindowStyle Hidden `
    -RedirectStandardOutput $helperStdout `
    -RedirectStandardError $helperStderr `
    -PassThru

$markerObserved = $false
for ($attempt = 0; $attempt -lt 200; $attempt += 1) {
    if (Test-Path -LiteralPath $readyFile -PathType Leaf) {
        $markerObserved = $true
        break
    }
    if ($helperProcess.HasExited) {
        break
    }
    Start-Sleep -Milliseconds 50
}
if (-not $markerObserved) {
    if (-not $helperProcess.HasExited) {
        $helperProcess.Kill()
        $helperProcess.WaitForExit()
    }
    throw "Crash helper did not reach the deterministic pre-COMMIT marker."
}

$actualHelperExecutable = [IO.Path]::GetFullPath($helperProcess.MainModule.FileName)
$expectedHelperExecutable = [IO.Path]::GetFullPath($godotExecutable)
if (-not $actualHelperExecutable.Equals($expectedHelperExecutable, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Crash helper identity mismatch for PID $($helperProcess.Id): $actualHelperExecutable"
}
$terminatedPid = $helperProcess.Id
$helperProcess.Kill()
$helperProcess.WaitForExit()
Write-Output "G3-01 EVIDENCE | terminated exact Godot helper PID $terminatedPid before COMMIT"

Invoke-GodotScript `
    -Script 'res://tests/g3_01/崩溃后验证.gd' `
    -UserArguments @(('--db={0}' -f $crashDatabase)) `
    -LogName 'crash-reopen.log'

if (-not $SkipExport) {
    $exportDirectory = Join-Path $projectRoot 'build\windows'
    New-Item -ItemType Directory -Force -Path $exportDirectory | Out-Null
    $exportExecutable = Join-Path $exportDirectory 'g3-01-persistence-spike.exe'
    $exportLog = Join-Path $expectedTestRoot 'export-build.log'
    & $godotExecutable --headless --path $projectRoot --log-file $exportLog --export-debug 'G3-01 Persistence Spike' $exportExecutable
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $exportExecutable -PathType Leaf)) {
        throw "Windows export failed with exit code $LASTEXITCODE"
    }

    $exportDatabase = (Join-Path $expectedTestRoot 'exported-exe.sqlite').Replace('\', '/')
    $exportRunLog = (Join-Path $expectedTestRoot 'exported-exe.log').Replace('\', '/')
    # Windows application control may reject the generated console wrapper; the exported main EXE
    # is the real product artifact and supplies an exact process/exit code without bypassing policy.
    $exportProcess = Start-Process `
        -FilePath $exportExecutable `
        -ArgumentList @('--headless', '--log-file', $exportRunLog, '--', ('--db={0}' -f $exportDatabase)) `
        -WindowStyle Hidden `
        -Wait `
        -PassThru
    if ($exportProcess.ExitCode -ne 0) {
        throw "Exported Windows EXE persistence smoke failed with exit code $($exportProcess.ExitCode)"
    }
    Get-Content -LiteralPath $exportRunLog -Encoding UTF8
}

Write-Output 'G3-01 PASS | real persistence validation harness completed'
