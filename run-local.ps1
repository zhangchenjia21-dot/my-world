[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Get-Item -LiteralPath $PSScriptRoot).FullName
$envFile = Join-Path $projectRoot '.env.local'
$godotExecutable = 'D:\AI\Engine\Godot_v4.7.2-stable_win64.exe'
$allowedVariables = @(
    'DEEPSEEK_API_KEY'
    'MY_WORLD_DEEPSEEK_MODEL'
)
$requiredVariables = @(
    'DEEPSEEK_API_KEY'
)

if (-not (Test-Path -LiteralPath $envFile -PathType Leaf)) {
    Write-Error -Message ("Missing local secret file: {0}" -f $envFile) -ErrorAction Continue
    exit 1
}

if (-not (Test-Path -LiteralPath $godotExecutable -PathType Leaf)) {
    Write-Error -Message ("Godot executable not found: {0}" -f $godotExecutable) -ErrorAction Continue
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

# Temporarily set variables in this PowerShell process; restore them after Godot exits.
$previousEnvironment = @{}
foreach ($name in $allowedVariables) {
    $environmentPath = 'Env:{0}' -f $name
    $existing = Get-Item -Path $environmentPath -ErrorAction SilentlyContinue
    $previousEnvironment[$name] = @{
        Exists = $null -ne $existing
        Value = if ($null -ne $existing) { [string]$existing.Value } else { $null }
    }
}

$godotExitCode = 1
try {
    foreach ($name in $allowedVariables) {
        $value = if ($localValues.ContainsKey($name)) { [string]$localValues[$name] } else { '' }
        Set-Item -Path ('Env:{0}' -f $name) -Value $value
    }

    $godotProcess = Start-Process -FilePath $godotExecutable `
        -ArgumentList @('--editor', '--path', $projectRoot) `
        -Wait `
        -PassThru
    $godotExitCode = [int]$godotProcess.ExitCode
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

exit $godotExitCode
