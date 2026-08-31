[CmdletBinding()]
param(
    [string]$GodotExecutable = 'D:\AI\Engine\Godot_v4.7.2-stable_win64_console.exe',
    [switch]$ValidateExportOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Owner product launch path: converge the ignored Windows export to the current
# checkout, read the local ignored .env.local, temporarily inject only the
# allowed variables, then start build/windows/my-world.exe.
# Never prints or logs any secret. ASCII-only on purpose: PowerShell 5.1 parses
# BOM-less .ps1 as ANSI, so non-ASCII literals would break parsing.

$projectRoot = (Get-Item -LiteralPath $PSScriptRoot).FullName
$envFile = Join-Path $projectRoot '.env.local'
$gameExecutable = Join-Path $projectRoot 'build\windows\my-world.exe'
$gamePack = Join-Path $projectRoot 'build\windows\my-world.pck'
$exportStamp = Join-Path $projectRoot 'build\windows\my-world.freshness.json'
$exportLog = Join-Path $projectRoot 'build\windows\owner-export.log'
$exportPreset = 'Windows Desktop'
$allowedVariables = @(
    'DEEPSEEK_API_KEY'
    'MY_WORLD_DEEPSEEK_MODEL'
)
$requiredVariables = @(
    'DEEPSEEK_API_KEY'
)

if (-not (Test-Path -LiteralPath $envFile -PathType Leaf)) {
    Write-Error -Message ("Missing local secret file: {0}`nCopy .env.example to .env.local and fill in your local DEEPSEEK_API_KEY." -f $envFile) -ErrorAction Continue
    exit 1
}

$localValues = @{}
$lineNumber = 0
foreach ($line in (Get-Content -LiteralPath $envFile)) {
    $lineNumber += 1
    $trimmedLine = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmedLine) -or $trimmedLine.StartsWith('#')) {
        continue
    }

    $separatorIndex = $trimmedLine.IndexOf('=')
    if ($separatorIndex -le 0) {
        Write-Error -Message ("Invalid .env.local line {0}: expected KEY=VALUE" -f $lineNumber) -ErrorAction Continue
        exit 1
    }

    $name = $trimmedLine.Substring(0, $separatorIndex).Trim()
    $value = $trimmedLine.Substring($separatorIndex + 1).Trim()
    if ($allowedVariables -notcontains $name) {
        Write-Error -Message ("Unsupported .env.local variable on line {0}: {1}" -f $lineNumber, $name) -ErrorAction Continue
        exit 1
    }
    if ($localValues.ContainsKey($name)) {
        Write-Error -Message ("Duplicate .env.local variable on line {0}: {1}" -f $lineNumber, $name) -ErrorAction Continue
        exit 1
    }

    $localValues[$name] = $value
}

$missingVariables = @(
    $requiredVariables | Where-Object {
        -not $localValues.ContainsKey($_) -or [string]::IsNullOrWhiteSpace([string]$localValues[$_])
    }
)
if ($missingVariables.Count -gt 0) {
    foreach ($name in $missingVariables) {
        Write-Error -Message ("{0}: missing" -f $name) -ErrorAction Continue
    }
    exit 1
}

function Get-ProductInputHash {
    $productFiles = @()
    foreach ($directoryName in @('src', 'addons')) {
        $directoryPath = Join-Path $projectRoot $directoryName
        if (Test-Path -LiteralPath $directoryPath -PathType Container) {
            $productFiles += @(Get-ChildItem -LiteralPath $directoryPath -Recurse -Force -File)
        }
    }
    foreach ($fileName in @('project.godot', 'export_presets.cfg')) {
        $filePath = Join-Path $projectRoot $fileName
        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            throw "Required product-build input is missing: $filePath"
        }
        $productFiles += @(Get-Item -LiteralPath $filePath)
    }

    $rootPrefix = [IO.Path]::GetFullPath($projectRoot).TrimEnd('\') + '\'
    $manifestEntries = @(
        $productFiles |
            Sort-Object -Property FullName |
            ForEach-Object {
                $relativePath = $_.FullName.Substring($rootPrefix.Length).Replace('\', '/')
                $fileStream = [IO.File]::OpenRead($_.FullName)
                $fileHasher = [Security.Cryptography.SHA256]::Create()
                try {
                    $fileHash = ([BitConverter]::ToString($fileHasher.ComputeHash($fileStream))).Replace('-', '').ToLowerInvariant()
                }
                finally {
                    $fileStream.Dispose()
                    $fileHasher.Dispose()
                }
                '{0}|{1}|{2}' -f $relativePath, $_.Length, $fileHash
            }
    )
    $manifestBytes = [Text.Encoding]::UTF8.GetBytes([string]::Join("`n", $manifestEntries))
    $sha256 = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha256.ComputeHash($manifestBytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha256.Dispose()
    }
}

function Test-ExportIsCurrent {
    param([Parameter(Mandatory = $true)][string]$InputHash)

    if (-not (Test-Path -LiteralPath $gameExecutable -PathType Leaf) -or
        -not (Test-Path -LiteralPath $gamePack -PathType Leaf) -or
        -not (Test-Path -LiteralPath $exportStamp -PathType Leaf)) {
        return $false
    }
    try {
        $stamp = Get-Content -LiteralPath $exportStamp -Raw | ConvertFrom-Json
        return [string]$stamp.schema -eq 'my-world.owner-export-freshness.v1' -and
            [string]$stamp.input_hash -eq $InputHash -and
            [string]$stamp.preset -eq $exportPreset -and
            [string]$stamp.target -eq 'build/windows/my-world.exe'
    }
    catch {
        return $false
    }
}

function Invoke-CurrentWindowsExport {
    param([Parameter(Mandatory = $true)][string]$InputHash)

    if (-not (Test-Path -LiteralPath $GodotExecutable -PathType Leaf)) {
        Write-Error -Message ("Godot executable not found: {0}`nInstall or restore Godot 4.7.2 at the configured path." -f $GodotExecutable) -ErrorAction Continue
        exit 1
    }
    $outputDirectory = Split-Path -Parent $gameExecutable
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

    # Once an export is known stale it loses launch eligibility. Removing only
    # the exact ignored outputs prevents a failed rebuild from falling back to it.
    foreach ($outputPath in @($gameExecutable, $gamePack, $exportStamp)) {
        if (Test-Path -LiteralPath $outputPath) {
            Remove-Item -LiteralPath $outputPath -Force
        }
    }

    Write-Output ("Windows export is missing or stale; rebuilding preset '{0}'." -f $exportPreset)
    & $GodotExecutable --headless --path $projectRoot --log-file $exportLog --export-debug $exportPreset $gameExecutable
    $exportExitCode = $LASTEXITCODE
    if ($exportExitCode -ne 0 -or
        -not (Test-Path -LiteralPath $gameExecutable -PathType Leaf) -or
        -not (Test-Path -LiteralPath $gamePack -PathType Leaf) -or
        (Get-Item -LiteralPath $gameExecutable).Length -le 0 -or
        (Get-Item -LiteralPath $gamePack).Length -le 0) {
        Write-Error -Message ("Windows export failed (exit {0}); the stale executable will not be launched. See {1}" -f $exportExitCode, $exportLog) -ErrorAction Continue
        exit 1
    }

    $verifiedHash = Get-ProductInputHash
    if ($verifiedHash -ne $InputHash) {
        Write-Error -Message 'Product-build inputs changed during export; refusing to launch a mismatched executable. Run again.' -ErrorAction Continue
        exit 1
    }

    $stampObject = [ordered]@{
        schema = 'my-world.owner-export-freshness.v1'
        input_hash = $verifiedHash
        preset = $exportPreset
        target = 'build/windows/my-world.exe'
        built_at_utc = [DateTime]::UtcNow.ToString('o')
    }
    $temporaryStamp = $exportStamp + '.tmp'
    $stampObject | ConvertTo-Json | Set-Content -LiteralPath $temporaryStamp -Encoding UTF8
    Move-Item -LiteralPath $temporaryStamp -Destination $exportStamp -Force
    if (-not (Test-ExportIsCurrent -InputHash $verifiedHash)) {
        Write-Error -Message 'Windows export completed but freshness verification failed; refusing to launch.' -ErrorAction Continue
        exit 1
    }
    Write-Output 'Windows export rebuilt and verified against the current checkout.'
}

$productInputHash = Get-ProductInputHash
if (Test-ExportIsCurrent -InputHash $productInputHash) {
    Write-Output 'Windows export is current; skipping rebuild.'
}
else {
    Invoke-CurrentWindowsExport -InputHash $productInputHash
}

if ($ValidateExportOnly) {
    Write-Output 'Windows export freshness validation completed; game launch skipped by explicit validation mode.'
    exit 0
}

# Temporarily set variables in this PowerShell process; restore them after the game exits.
$previousEnvironment = @{}
foreach ($name in $allowedVariables) {
    $environmentPath = 'Env:{0}' -f $name
    $existing = Get-Item -Path $environmentPath -ErrorAction SilentlyContinue
    $previousEnvironment[$name] = @{
        Exists = $null -ne $existing
        Value = if ($null -ne $existing) { [string]$existing.Value } else { $null }
    }
}

$gameExitCode = 1
try {
    foreach ($name in $allowedVariables) {
        $value = if ($localValues.ContainsKey($name)) { [string]$localValues[$name] } else { '' }
        Set-Item -Path ('Env:{0}' -f $name) -Value $value
    }

    $gameProcess = Start-Process -FilePath $gameExecutable `
        -WorkingDirectory (Split-Path -Parent $gameExecutable) `
        -Wait `
        -PassThru
    $gameExitCode = [int]$gameProcess.ExitCode
}
finally {
    foreach ($name in $allowedVariables) {
        $environmentPath = 'Env:{0}' -f $name
        $previous = $previousEnvironment[$name]
        if ($previous.Exists) {
            Set-Item -Path $environmentPath -Value $previous.Value
        }
        else {
            Remove-Item -Path $environmentPath -ErrorAction SilentlyContinue
        }
    }
}

exit $gameExitCode
