[CmdletBinding()]
param([string]$Godot = 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe', [string]$Root = '')
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
if (-not $Root) { $Root = Join-Path $projectRoot ('build/mw019/verify-' + (Get-Date -Format 'yyyyMMdd-HHmmss')) }
$Root = [IO.Path]::GetFullPath($Root)
if (-not $Root.StartsWith(($projectRoot + '\build\mw019\'), [StringComparison]::OrdinalIgnoreCase)) { throw 'Use task-owned build/mw019 root.' }
if (Test-Path -LiteralPath $Root) { throw 'Evidence root must be new.' }
New-Item -ItemType Directory -Force $Root | Out-Null
# R1 的 focused/UI gate 先单独执行；这里依次验证既有纵向、提交/判定及受影响历史。
$cases = @(
    @('mw019-lifecycle', 'tests/mw019/行动推荐纵向测试.gd'),
    @('mw019-routes', 'tests/mw019/行动推荐发送判定测试.gd'),
    @('g2_03', 'tests/g2_03_会话视图离线测试.gd'),
    @('g2_04', 'tests/g2_04_会话域离线测试.gd'),
    @('g4_08b', 'tests/g4_08b/公开D20界面整合测试.gd'),
    @('g4_08m1', 'tests/g4_08m1/公开D20机制测试.gd'),
    @('g4_08m1-idempotency', 'tests/g4_08m1/NO_CHECK行动幂等修复测试.gd'),
    @('mw018-r1', 'tests/mw018/已知场外人物资格纵向测试.gd'),
    @('mw018', 'tests/mw018/人物整理卡片纵向测试.gd'),
    @('mw015-r1', 'tests/mw015/稀疏重要经历纵向测试.gd'),
    @('mw015', 'tests/mw015/角色与重要经历界面测试.gd'),
    @('mw015r2-ui', 'tests/mw015r2/初始角色界面纵向测试.gd'),
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
    # Task Packet 要求 bounded real Provider 后才做最终 import/export；此 runner 不导出。

}
finally {
    foreach ($name in $previous.Keys) { [Environment]::SetEnvironmentVariable($name,$previous[$name],'Process') }
    $results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $Root 'results.json') -Encoding utf8
}
if (@($results | Where-Object { $_.exit_code -ne 0 -or $_.errors -ne 0 }).Count) { exit 1 }
