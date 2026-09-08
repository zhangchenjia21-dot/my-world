[CmdletBinding()]
param(
    [ValidateSet('Focused', 'Window', 'Regressions')][string]$Mode = 'Focused',
    [string]$Godot = 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe'
)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$runName = 'mw024-' + (Get-Date -Format 'HHmmss')
$evidenceRoot = Join-Path $projectRoot ('build/mw024/' + $runName)
New-Item -ItemType Directory $evidenceRoot | Out-Null
switch ($Mode) {
    'Focused' { $cases = @(@('mw024-contract','tests/mw024/输入模式兼容契约测试.gd'), @('mw024-vertical','tests/mw024/场外指导纵向测试.gd')) }
    'Window' { $cases = ,@('mw024-window','tests/mw024/场外指导纵向测试.gd') }
    'Regressions' { $cases = @(
        @('g2_03', 'tests/g2_03_会话视图离线测试.gd'),
        @('g2_04', 'tests/g2_04_会话域离线测试.gd'),
        @('g2_05', 'tests/g2_05_上下文组装离线测试.gd'),
        @('g3_03-contract','tests/g3_03/会话恢复与候选测试.gd'),
        @('g3_03-persistence','tests/g3_03/持久化迁移与生命周期测试.gd'),
        @('g3_04-contract','tests/g3_04/会话恢复验证测试.gd'),
        @('g3_04-persistence','tests/g3_04/存档恢复持久化测试.gd'),
        @('g3_05-persistence','tests/g3_05/恢复时间线持久化测试.gd'),
        @('g4_08m1','tests/g4_08m1/公开D20机制测试.gd'),
        @('g4_08m1-no-check','tests/g4_08m1/NO_CHECK行动幂等修复测试.gd'),
        @('g4_08b','tests/g4_08b/公开D20界面整合测试.gd'),
        @('g5_01','tests/g5_01/世界回合语义物化测试.gd'),
        @('g5_02','tests/g5_02/已知角色知识溯源测试.gd'),
        @('g5_03','tests/g5_03/多角色行动代理循环测试.gd'),
        @('g5_03m2b','tests/g5_03m2b/运行时叙事演员物化测试.gd'),
        @('g5_04','tests/g5_04/选择性世界演化评估测试.gd'),
        @('mw023','tests/mw023/游戏字号窗口验证.gd'),
        @('mw003', 'tests/mw003/视觉舒适主题验证测试.gd'),
        @('mw011', 'tests/mw011/G6主机视图模型基线测试.gd'),
        @('mw022', 'tests/mw022/会话调试观测纵向测试.gd'),
        @('mw022-ui', 'tests/mw022/会话调试窗口测试.gd'),
        @('g5_01-timeline', 'tests/g5_01/世界回合时间线恢复测试.gd'),
        @('mw017', 'tests/mw017/人物身份桥屏障纵向测试.gd'),
        @('mw014', 'tests/mw014/模型信息整理纵向测试.gd'),
        @('mw015r2', 'tests/mw015r2/初始角色基线纵向测试.gd'),
        @('mw015r2-ui', 'tests/mw015r2/初始角色界面纵向测试.gd'),
        @('mw015', 'tests/mw015/角色与重要经历界面测试.gd'),
        @('mw015r1', 'tests/mw015/稀疏重要经历纵向测试.gd'),
        @('mw018', 'tests/mw018/人物整理卡片纵向测试.gd'),
        @('mw018r1', 'tests/mw018/已知场外人物资格纵向测试.gd'),
        @('mw019-lifecycle', 'tests/mw019/行动推荐纵向测试.gd'),
        @('mw019-pairs', 'tests/mw019/推荐成对契约界面测试.gd'),
        @('mw019-routes', 'tests/mw019/行动推荐发送判定测试.gd'),
        @('g3_03', 'tests/g3_03/上下文恢复与界面测试.gd'),
        @('g3_04', 'tests/g3_04/存档读取界面测试.gd'),
        @('g3_05', 'tests/g3_05/恢复进度界面测试.gd'),
        @('mw021', 'tests/mw021/叙事滚动导航测试.gd')
    ) }
}
# 所有验证使用既有 stub/隔离数据，不向真实 Provider 发送请求。
$previous = @{}
foreach ($name in @('DEEPSEEK_API_KEY', 'KIMI_API_KEY')) {
    $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
    [Environment]::SetEnvironmentVariable($name, '', 'Process')
}
$results = @()
try {
    foreach ($case in $cases) {
        # 短路径避免冻结 Source fixture 的 Windows 路径长度问题；每个 case 全新。
        $caseRoot = Join-Path $projectRoot ('build/' + $case[0] + '/' + $runName + '-f')
        New-Item -ItemType Directory $caseRoot | Out-Null
        $log = Join-Path $evidenceRoot ($case[0] + '.log')
        [string[]]$displayArgs = if ($Mode -eq 'Window' -or $case[0] -in @('mw003','mw022-ui')) { @() } else { @('--headless') }
        $userArgs = @(('--root=' + $caseRoot.Replace('\','/')), ('--db=' + (Join-Path $caseRoot 'ui.sqlite').Replace('\','/')))
        if ($Mode -eq 'Window') { $userArgs += '--visual' }
        if ($case[0] -eq 'mw015r2-ui') { $userArgs += '--model-evidence=res://docs/mw015/r2/evidence/real-initial-attempt-02.json' }
        & $Godot @displayArgs --path $projectRoot --script ('res://' + $case[1]) -- @userArgs *> $log
        $code = $LASTEXITCODE
        $errors = @(Select-String -LiteralPath $log -CaseSensitive -Pattern 'SCRIPT ERROR:|Parse Error:|\bFAIL[ :|]')
        $warnings = @(Select-String -LiteralPath $log -Pattern 'leaked at exit|resources still in use')
        $results += @{ name=$case[0]; exit_code=$code; errors=$errors.Count; exit_warnings=$warnings.Count; log=$log; fixture=$caseRoot }
        Write-Output ($case[0] + ' exit=' + $code + ' errors=' + $errors.Count + ' exit_warnings=' + $warnings.Count)
    }
}
finally {
    foreach ($name in $previous.Keys) { [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process') }
    $results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $evidenceRoot 'results.json') -Encoding utf8
}
Write-Output $evidenceRoot
if (@($results | Where-Object { $_.exit_code -ne 0 -or $_.errors -ne 0 }).Count) { exit 1 }
