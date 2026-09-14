[CmdletBinding()]
param([ValidateSet('Focused','Regressions','Window')][string]$Mode='Focused')
$ErrorActionPreference='Stop'
$projectRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
if ($Mode -ne 'Focused') {
    & (Join-Path $projectRoot 'tests/mw033/运行工作集验证.ps1') -Mode $Mode
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if ($Mode -eq 'Regressions') { & (Join-Path $projectRoot 'tests/mw033/运行工作集验证.ps1') -Mode Focused }
    exit $LASTEXITCODE
}
$fixture=Join-Path $projectRoot ('build/mw034/focused-'+(Get-Date -Format 'HHmmss'))
New-Item -ItemType Directory -Path $fixture | Out-Null
$log=Join-Path $fixture 'focused.log'
& 'D:/AI/Engine/Godot_v4.7.2-stable_win64_console.exe' --headless --path $projectRoot --quit-after 6000 --script res://tests/mw034/信息整理恢复纵向测试.gd -- ('--root='+$fixture.Replace('\','/')) *> $log
$code=$LASTEXITCODE
Get-Content -LiteralPath $log -Tail 3
Write-Output $fixture
if ($code -ne 0 -or (Select-String -LiteralPath $log -Pattern 'SCRIPT ERROR:|Parse Error:|FAIL ')) { exit 1 }
exit 0
