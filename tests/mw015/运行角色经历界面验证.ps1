[CmdletBinding()]
param(
    [string]$Godot = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe',
    [string]$Root = ''
)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
if ([string]::IsNullOrEmpty($Root)) { $Root = Join-Path $projectRoot ('build/mw015/verify-' + (Get-Date -Format 'yyyyMMdd-HHmmss')) }
$Root = [IO.Path]::GetFullPath($Root)
if (-not $Root.StartsWith(($projectRoot + '\build\mw015\'), [StringComparison]::OrdinalIgnoreCase)) { throw 'Verification root must stay in this worktree build/mw015.' }
if (Test-Path -LiteralPath $Root) { throw 'Use a fresh verification root; existing evidence is preserved.' }
New-Item -ItemType Directory -Force -Path $Root | Out-Null
$previous = @{}
foreach ($name in @('DEEPSEEK_API_KEY', 'KIMI_API_KEY')) {
    $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
    [Environment]::SetEnvironmentVariable($name, '', 'Process')
}
# focused-first：MW-015 focused 全绿后才跑 packet 指定的最小 affected regressions。
# real Provider calls = 0。mw010 / g4_07b 整合+布局（GUI 痕迹类）单独验证：断言全绿，
# exit 时 ObjectDB leaked / resources in use 计数与 base fdf901b 完全一致（pre-existing，见 evidence）。
$cases = @(
    @('focused', 'tests/mw015/角色与重要经历界面测试.gd', 'mw015'),
    @('mw014', 'tests/mw014/模型信息整理纵向测试.gd', 'mw014'),
    @('g304', 'tests/g3_04/存档恢复持久化测试.gd', 'g304'),
    @('g501-materialization', 'tests/g5_01/世界回合语义物化测试.gd', 'g5_01-materialization'),
    @('g501-timeline', 'tests/g5_01/世界回合时间线恢复测试.gd', 'g5_01-timeline'),
    @('mw009', 'tests/mw009/玩家安全侧栏投影测试.gd', 'mw009'),
    @('mw011', 'tests/mw011/G6主机视图模型基线测试.gd', 'mw011'),
    @('mw011r2', 'tests/mw011r2/玩家档案表面测试.gd', 'mw011r2'),
    @('mw012', 'tests/mw012/张琛角色卡集成测试.gd', 'mw012')
)
$results = @()
try {
    foreach ($case in $cases) {
        $log = Join-Path $Root ($case[0] + '.log')
        $caseRoot = (Join-Path $Root $case[2]).Replace('\', '/')
        $extraArgs = @('--root=' + $caseRoot)
        if ($case[0] -eq 'g407b-layout') {
            $shotDir = Join-Path $Root 'shots'
            New-Item -ItemType Directory -Force -Path $shotDir | Out-Null
            $extraArgs += '--shot-dir=' + $shotDir.Replace('\', '/')
        }
        # PS 5.1 下 native stderr（如测试故意的 migration failure 日志）会被包成 ErrorRecord；
        # 局部降为 Continue，退出码仍经 $LASTEXITCODE 判定。
        $ErrorActionPreference = 'Continue'
        & $Godot --headless --path $projectRoot --script ('res://' + $case[1]) -- $extraArgs *> $log
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = 'Stop'
        $scriptErrors = @(Select-String -LiteralPath $log -Pattern 'SCRIPT ERROR:|Parse Error:|leaked at exit|resources still in use')
        $results += @{ name = $case[0]; exit_code = $exitCode; script_errors = $scriptErrors.Count; log = $log }
        Write-Output ($case[0] + ' exit=' + $exitCode + ' script_errors=' + $scriptErrors.Count)
        if ($exitCode -ne 0 -or $scriptErrors.Count -ne 0) { throw ('Verification failed: ' + $case[0]) }
    }
    $windows = Join-Path $Root 'windows'
    New-Item -ItemType Directory -Force -Path $windows | Out-Null
    $exportLog = Join-Path $Root 'windows-export.log'
    $ErrorActionPreference = 'Continue'
    & $Godot --headless --path $projectRoot --export-release 'Windows Desktop' (Join-Path $windows 'my-world.exe') *> $exportLog
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    $scriptErrors = @(Select-String -LiteralPath $exportLog -Pattern 'SCRIPT ERROR:|Parse Error:|ERROR:')
    $results += @{ name = 'windows-export'; exit_code = $exitCode; script_errors = $scriptErrors.Count; log = $exportLog }
    Write-Output ('windows-export exit=' + $exitCode + ' errors=' + $scriptErrors.Count)
    if ($exitCode -ne 0 -or $scriptErrors.Count -ne 0) { throw 'Windows export failed.' }
}
finally {
    foreach ($name in $previous.Keys) { [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process') }
    $results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $Root 'results.json') -Encoding utf8
}
