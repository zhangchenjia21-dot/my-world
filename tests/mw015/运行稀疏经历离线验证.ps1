[CmdletBinding()]
param([string]$Godot = 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe', [string]$Root = '')
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
if (-not $Root) { $Root = Join-Path $projectRoot ('build/mw015/r1/verify-' + (Get-Date -Format 'yyyyMMdd-HHmmss')) }
$Root = [IO.Path]::GetFullPath($Root)
if (-not $Root.StartsWith(($projectRoot + '\build\mw015\r1\'), [StringComparison]::OrdinalIgnoreCase)) { throw 'Use task-owned build/mw018 root.' }
if (Test-Path -LiteralPath $Root) { throw 'Evidence root must be new.' }
New-Item -ItemType Directory -Force $Root | Out-Null
$cases = @(
    @('mw015r1', 'tests/mw015/稀疏重要经历纵向测试.gd'),
    @('mw014', 'tests/mw014/模型信息整理纵向测试.gd'),
    @('mw015', 'tests/mw015/角色与重要经历界面测试.gd'),
    @('mw015r2', 'tests/mw015r2/初始角色基线纵向测试.gd'),
    @('mw015r2-ui', 'tests/mw015r2/初始角色界面纵向测试.gd'),
    @('mw015r2-contract', 'tests/mw015r2/初始整理契约缺口验证.gd'),
    @('mw017', 'tests/mw017/人物身份桥屏障纵向测试.gd'),
    @('mw018', 'tests/mw018/人物整理卡片纵向测试.gd'),
    @('mw018r1', 'tests/mw018/已知场外人物资格纵向测试.gd'),
    @('g5_01-timeline', 'tests/g5_01/世界回合时间线恢复测试.gd')
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
        $errors = @(Select-String -LiteralPath $log -Pattern 'SCRIPT ERROR:|Parse Error:|FAIL ')
        $warnings = @(Select-String -LiteralPath $log -Pattern 'leaked at exit|resources still in use')
        $results += @{ name=$case[0]; exit_code=$code; errors=$errors.Count; exit_warnings=$warnings.Count; log=$log }
        Write-Output ($case[0] + ' exit=' + $code + ' errors=' + $errors.Count + ' exit_warnings=' + $warnings.Count)
    }

}
finally {
    foreach ($name in $previous.Keys) { [Environment]::SetEnvironmentVariable($name,$previous[$name],'Process') }
    $results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $Root 'results.json') -Encoding utf8
}
if (@($results | Where-Object { $_.exit_code -ne 0 -or $_.errors -ne 0 }).Count) { exit 1 }
