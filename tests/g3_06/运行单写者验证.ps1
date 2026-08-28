[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName
$godotExecutable = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe'
$testRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_06_single_writer'))
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build\g3_06_single_writer'))
if (-not $testRoot.Equals($expectedRoot, [StringComparison]::OrdinalIgnoreCase) -or
    -not $testRoot.StartsWith(($projectRoot + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing unsafe G3-06 test root: $testRoot"
}
if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
New-Item -ItemType Directory -Path $testRoot | Out-Null

$database = (Join-Path $testRoot 'current.sqlite').Replace('\', '/')
$ready = Join-Path $testRoot 'owner-a.ready'
$helperScript = 'res://tests/g3_06/单写者进程助手.gd'
$ownerArgs = @(
    '--headless', '--path', $projectRoot,
    '--log-file', (Join-Path $testRoot 'owner-a.godot.log'),
    '--script', $helperScript, '--',
    '--mode=hold', ('--db={0}' -f $database), ('--ready={0}' -f $ready.Replace('\', '/'))
)
$owner = Start-Process -FilePath $godotExecutable -ArgumentList $ownerArgs -WindowStyle Hidden `
    -RedirectStandardOutput (Join-Path $testRoot 'owner-a.stdout.log') `
    -RedirectStandardError (Join-Path $testRoot 'owner-a.stderr.log') -PassThru

for ($attempt = 0; $attempt -lt 200 -and -not (Test-Path -LiteralPath $ready -PathType Leaf); $attempt += 1) {
    if ($owner.HasExited) { break }
    Start-Sleep -Milliseconds 50
}
if (-not (Test-Path -LiteralPath $ready -PathType Leaf)) {
    if (-not $owner.HasExited) { $owner.Kill(); $owner.WaitForExit() }
    throw 'Owner A did not reach the deterministic writer-owned marker.'
}
$markerPid = [int]((Get-Content -LiteralPath $ready | Where-Object { $_ -like 'pid=*' }) -replace '^pid=', '')
$ownerRuntimeProcess = Get-Process -Id $markerPid -ErrorAction Stop
$actualExecutable = [IO.Path]::GetFullPath($ownerRuntimeProcess.MainModule.FileName)
$expectedHelperExecutable = [IO.Path]::GetFullPath('D:\AI\Engine\Godot_v4.7.2-stable_win64.exe')
if (-not $actualExecutable.Equals($expectedHelperExecutable, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Owner A executable identity mismatch for PID ${markerPid}: $actualExecutable"
}
$databaseBefore = Get-Item -LiteralPath $database
$lengthBefore = $databaseBefore.Length
$writeTimeBefore = $databaseBefore.LastWriteTimeUtc
& $godotExecutable --headless --path $projectRoot --log-file (Join-Path $testRoot 'process-b.godot.log') `
    --script $helperScript -- '--mode=probe_blocked' ('--db={0}' -f $database)
if ($LASTEXITCODE -ne 0) { throw 'Process B single-writer probe failed.' }
$databaseAfter = Get-Item -LiteralPath $database
if ($databaseAfter.Length -ne $lengthBefore -or $databaseAfter.LastWriteTimeUtc -ne $writeTimeBefore) {
    throw 'Process B changed gameplay DB file metadata before rejection.'
}

$terminatedPid = $markerPid
$ownerRuntimeProcess.Kill()
$ownerRuntimeProcess.WaitForExit()
Write-Output "G3-06 SINGLE WRITER EVIDENCE | exact owner A PID $terminatedPid terminated"

& $godotExecutable --headless --path $projectRoot --log-file (Join-Path $testRoot 'process-c.godot.log') `
    --script $helperScript -- '--mode=probe_reopen' ('--db={0}' -f $database)
if ($LASTEXITCODE -ne 0) { throw 'Process C could not acquire crash-released ownership.' }
Write-Output 'G3-06 SINGLE WRITER PASS | B rejected without gameplay touch; crash automatically released OS-backed lock'
