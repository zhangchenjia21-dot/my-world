[CmdletBinding()]
param(
    [switch]$Reopen
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName
$godotConsole = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
$godotProduct = 'D:\AI\Engine\Godot_v4.7.2-stable_win64.exe'
$uatRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_06_owner_uat'))
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_06_owner_uat'))
if (-not $uatRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    -not $uatRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing unsafe G3-06 Owner UAT root: $uatRoot"
}
$database = (Join-Path $uatRoot 'current-game.sqlite').Replace('\', '/')

if (-not $Reopen) {
    # 只重建明确 task-owned fixture；绝不读取、复制、改写默认 user:// Current Game。
    if (Test-Path -LiteralPath $uatRoot) { Remove-Item -LiteralPath $uatRoot -Recurse -Force }
    New-Item -ItemType Directory -Path $uatRoot | Out-Null
    & $godotConsole --headless --path $projectRoot --log-file (Join-Path $uatRoot 'prepare.log') `
        --script 'res://tests/g3_06/安全流程崩溃夹具.gd' -- '--mode=seed_corrupt' ("--db=$database")
    if ($LASTEXITCODE -ne 0) { throw 'Could not prepare isolated G3-06 Owner UAT fixture.' }
    Write-Output '已准备隔离损坏数据库。请在界面确认：损坏说明、进度可能丢失、原件保留、恢复按钮与二次确认。'
} else {
    if (-not (Test-Path -LiteralPath $database -PathType Leaf)) {
        throw 'Isolated recovered database is missing. Run without -Reopen first.'
    }
    Write-Output '正在重新打开隔离数据库；请确认恢复后的 Game/存档可正常继续。'
}

Start-Process -FilePath $godotProduct -ArgumentList @(
    '--path', $projectRoot, '--', ("--current-game-db=$database")
) -WindowStyle Normal | Out-Null
