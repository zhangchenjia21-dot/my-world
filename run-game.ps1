[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# G2-03 Owner product launch path: read the local ignored .env.local, temporarily
# inject only the G2-allowed variables, then start the exported build/windows/my-world.exe.
# Never prints or logs any secret. ASCII-only on purpose: PowerShell 5.1 parses
# BOM-less .ps1 as ANSI, so non-ASCII literals would break parsing.

$projectRoot = (Get-Item -LiteralPath $PSScriptRoot).FullName
$envFile = Join-Path $projectRoot '.env.local'
$gameExecutable = Join-Path $projectRoot 'build\windows\my-world.exe'
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

if (-not (Test-Path -LiteralPath $gameExecutable -PathType Leaf)) {
    Write-Error -Message ("Game executable not found: {0}`nWindows export is not built on this machine yet; ask the dev side to build it first." -f $gameExecutable) -ErrorAction Continue
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
