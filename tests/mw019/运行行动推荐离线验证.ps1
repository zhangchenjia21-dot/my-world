[CmdletBinding()]
param([string]$Godot = 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe', [string]$Root = '')
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
if (-not $Root) { $Root = Join-Path $projectRoot ('build/mw019/verify-' + (Get-Date -Format 'yyyyMMdd-HHmmss')) }
$Root = [IO.Path]::GetFullPath($Root)
if (-not $Root.StartsWith(($projectRoot + '\build\mw019\'), [StringComparison]::OrdinalIgnoreCase)) { throw 'Use task-owned build/mw019 root.' }
if (Test-Path -LiteralPath $Root) { throw 'Evidence root must be new.' }
New-Item -ItemType Directory -Force $Root | Out-Null
$cases = @(
    @('mw019-focused', 'tests/mw019/行动推荐纵向测试.gd'),
    @('mw019-routes', 'tests/mw019/行动推荐发送判定测试.gd'),
    @('g2_03', 'tests/g2_03_会话视图离线测试.gd'),
    @('g2_04', 'tests/g2_04_会话域离线测试.gd'),
    @('g2_05', 'tests/g2_05_上下文组装离线测试.gd'),
    @('g4_07a', 'tests/g4_07a/首次开场运行时聚焦测试.gd'),
    @('g4_08b', 'tests/g4_08b/公开D20界面整合测试.gd'),
    @('g4_08m1', 'tests/g4_08m1/公开D20机制测试.gd'),
    @('g4_08m1-idempotency', 'tests/g4_08m1/NO_CHECK行动幂等修复测试.gd'),
    @('g4_09uatbc02a', 'tests/g4_09uatbc02a/公开D20协议解耦测试.gd'),
    @('mw018', 'tests/mw018/人物整理卡片纵向测试.gd'),
    @('mw017', 'tests/mw017/人物身份桥屏障纵向测试.gd'),
    @('g5_01', 'tests/g5_01/世界回合语义物化测试.gd'),
    @('g5_01-timeline', 'tests/g5_01/世界回合时间线恢复测试.gd'),
    @('g5_02', 'tests/g5_02/已知角色知识溯源测试.gd'),
    @('g5_03', 'tests/g5_03/多角色行动代理循环测试.gd'),
    @('g5_03m2a', 'tests/g5_03m2a/稳定演员注册表基础测试.gd'),
    @('g5_03m2b', 'tests/g5_03m2b/运行时叙事演员物化测试.gd'),
    @('g5_04', 'tests/g5_04/选择性世界演化评估测试.gd'),
    @('mw006', 'tests/mw006/机制锚定世界后果垂直测试.gd'),
    @('mw014', 'tests/mw014/模型信息整理纵向测试.gd'),
    @('mw015', 'tests/mw015/角色与重要经历界面测试.gd'),
    @('mw015r2', 'tests/mw015r2/初始角色基线纵向测试.gd'),
    @('mw015r2-ui', 'tests/mw015r2/初始角色界面纵向测试.gd'),
    @('mw015r2-contract', 'tests/mw015r2/初始整理契约缺口验证.gd'),
    @('g4_07b', 'tests/g4_07b/可玩界面整合测试.gd')
)
$previous = @{}
foreach ($name in @('DEEPSEEK_API_KEY','KIMI_API_KEY')) {
    $previous[$name] = [Environment]::GetEnvironmentVariable($name,'Process')
    [Environment]::SetEnvironmentVariable($name,'','Process')
}
$results = @()
try {
    foreach ($case in $cases) {
        $log = Join-Path $Root ($case[0] + '.log')
        $argsForTest = @('--root=' + (Join-Path $Root $case[0]).Replace('\','/'))
        if ($case[0] -eq 'mw015r2-ui') { $argsForTest += '--model-evidence=res://docs/mw015/r2/evidence/real-initial-attempt-02.json' }
        & $Godot --headless --path $projectRoot --script ('res://' + $case[1]) -- @argsForTest *> $log
        $code = $LASTEXITCODE
        $errors = @(Select-String -LiteralPath $log -CaseSensitive -Pattern 'SCRIPT ERROR:|Parse Error:|\bFAIL[ :|]')
        $warnings = @(Select-String -LiteralPath $log -Pattern 'leaked at exit|resources still in use')
        $results += @{ name=$case[0]; exit_code=$code; errors=$errors.Count; exit_warnings=$warnings.Count; log=$log }
        Write-Output ($case[0] + ' exit=' + $code + ' errors=' + $errors.Count + ' exit_warnings=' + $warnings.Count)
    }
    $windows = Join-Path $Root 'windows'
    New-Item -ItemType Directory -Force $windows | Out-Null
    $log = Join-Path $Root 'windows-export.log'
    & $Godot --headless --path $projectRoot --export-release 'Windows Desktop' (Join-Path $windows 'my-world.exe') *> $log
    $code = $LASTEXITCODE
    $errors = @(Select-String -LiteralPath $log -Pattern 'SCRIPT ERROR:|Parse Error:|ERROR:')
    $results += @{ name='windows-export'; exit_code=$code; errors=$errors.Count; log=$log }
    Write-Output ('windows-export exit=' + $code + ' errors=' + $errors.Count)
}
finally {
    foreach ($name in $previous.Keys) { [Environment]::SetEnvironmentVariable($name,$previous[$name],'Process') }
    $results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $Root 'results.json') -Encoding utf8
}
if (@($results | Where-Object { $_.exit_code -ne 0 -or $_.errors -ne 0 }).Count) { exit 1 }
