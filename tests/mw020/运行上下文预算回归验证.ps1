[CmdletBinding()]
param([string]$Godot='D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe', [string]$Root='')
$ErrorActionPreference='Stop'
$projectRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
if (-not $Root) { $Root=Join-Path $projectRoot ('build/mw020/regressions-'+(Get-Date -Format 'yyyyMMdd-HHmmss')) }
$Root=[IO.Path]::GetFullPath($Root)
if (-not $Root.StartsWith($projectRoot+'\build\mw020\',[StringComparison]::OrdinalIgnoreCase) -or (Test-Path -LiteralPath $Root)) { throw 'Use a fresh task-owned build/mw020 root.' }
New-Item -ItemType Directory -Path $Root | Out-Null
# 在 focused accounting gate 之后执行；覆盖四族投影、替换/恢复及真实 GM consumer。
$cases=@(
 @('g5_01-semantic','tests/g5_01/世界回合语义物化测试.gd'),
 @('g5_01-timeline','tests/g5_01/世界回合时间线恢复测试.gd'),
 @('g5_02','tests/g5_02/已知角色知识溯源测试.gd'),
 @('g5_03','tests/g5_03/多角色行动代理循环测试.gd'),
 @('g5_04','tests/g5_04/选择性世界演化评估测试.gd'),
 @('mw007','tests/mw007/机制后果时间线连续性测试.gd')
)
$previous=@{}
foreach ($name in @('DEEPSEEK_API_KEY','KIMI_API_KEY')) {
 $previous[$name]=[Environment]::GetEnvironmentVariable($name,'Process')
 [Environment]::SetEnvironmentVariable($name,'','Process')
}
$results=@()
try {
 foreach ($case in $cases) {
  $log=Join-Path $Root ($case[0]+'.log')
  & $Godot --headless --path $projectRoot --script ('res://'+$case[1]) -- ('--root='+(Join-Path $Root $case[0]).Replace('\','/')) *> $log
  $code=$LASTEXITCODE
  $errors=@(Select-String -LiteralPath $log -CaseSensitive -Pattern 'SCRIPT ERROR:|Parse Error:|\bFAIL[ :|]')
  $warnings=@(Select-String -LiteralPath $log -Pattern 'leaked at exit|resources still in use')
  $results+=@{name=$case[0];exit_code=$code;errors=$errors.Count;exit_warnings=$warnings.Count;log=$log}
  Write-Output ($case[0]+' exit='+$code+' errors='+$errors.Count+' exit_warnings='+$warnings.Count)
 }
}
finally {
 foreach ($name in $previous.Keys) { [Environment]::SetEnvironmentVariable($name,$previous[$name],'Process') }
 $results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $Root 'results.json') -Encoding utf8
}
if (@($results | Where-Object { $_.exit_code -ne 0 -or $_.errors -ne 0 }).Count) { exit 1 }
