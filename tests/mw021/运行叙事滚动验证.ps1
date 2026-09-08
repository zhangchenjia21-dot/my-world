[CmdletBinding()]
param([string]$Godot = 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe', [string[]]$Only = @())
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$evidenceRoot = Join-Path $projectRoot ('build/mw021/r' + (Get-Date -Format 'HHmmss'))
New-Item -ItemType Directory $evidenceRoot | Out-Null
$cases = @(
    @('g2-03', 'tests/g2_03_会话视图离线测试.gd'),
    @('g2-04', 'tests/g2_04_会话域离线测试.gd'),
    @('mw008', 'tests/mw008/安全轻量渲染测试.gd'),
    @('g3-03', 'tests/g3_03/上下文恢复与界面测试.gd'),
    @('g3-05', 'tests/g3_05/恢复进度界面测试.gd'),
    @('g4_09uatbc01', 'tests/g4_09uatbc01/叙事响应流式关键路径测试.gd'),
    @('mw003', 'tests/mw003/视觉舒适主题验证测试.gd'),
    @('mw011', 'tests/mw011/G6主机视图模型基线测试.gd'),
    @('mw019-paired', 'tests/mw019/推荐成对契约界面测试.gd'),
    @('mw019-routes', 'tests/mw019/行动推荐发送判定测试.gd')
)
$previous = @{}
foreach ($name in @('DEEPSEEK_API_KEY','KIMI_API_KEY')) {
    $previous[$name] = [Environment]::GetEnvironmentVariable($name,'Process')
    [Environment]::SetEnvironmentVariable($name,'','Process')
}
$results = @()
try {
    foreach ($case in $cases) {
        if ($Only.Count -and $case[0] -notin $Only) { continue }
        $caseRoot = Join-Path $evidenceRoot $case[0]
        New-Item -ItemType Directory $caseRoot | Out-Null
        $log = Join-Path $evidenceRoot ($case[0] + '.log')
        $displayArgs = if ($case[0] -eq 'mw003') { @('--rendering-method', 'gl_compatibility') } else { @('--headless') }
        & $Godot @displayArgs --path $projectRoot --script ('res://' + $case[1]) -- ('--root=' + $caseRoot.Replace('\','/')) ('--db=' + (Join-Path $caseRoot 'ui.sqlite').Replace('\','/')) *> $log
        $code = $LASTEXITCODE
        $errors = @(Select-String -LiteralPath $log -CaseSensitive -Pattern 'SCRIPT ERROR:|Parse Error:|\bFAIL[ :|]')
        $warnings = @(Select-String -LiteralPath $log -Pattern 'leaked at exit|resources still in use')
        $results += @{ name=$case[0]; exit_code=$code; errors=$errors.Count; exit_warnings=$warnings.Count; log=$log }
        Write-Output ($case[0] + ' exit=' + $code + ' errors=' + $errors.Count + ' exit_warnings=' + $warnings.Count)
    }
}
finally {
    foreach ($name in $previous.Keys) { [Environment]::SetEnvironmentVariable($name,$previous[$name],'Process') }
    $results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $evidenceRoot 'results.json') -Encoding utf8
}
if (@($results | Where-Object { $_.exit_code -ne 0 -or $_.errors -ne 0 }).Count) { exit 1 }
