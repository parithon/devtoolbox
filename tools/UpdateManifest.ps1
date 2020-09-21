[CmdletBinding()]
param()

# Ensure we have the Configuration module installed and imported
if ($null -eq (Get-Module Configuration -ListAvailable)) {
  Install-Module Configuration -Scope CurrentUser -Force
  Import-Module Configuration
}

# Change our working directory into the 'source' directory
Push-Location (Join-Path -Path (Convert-Path (Split-Path "$PSScriptRoot" -Parent)) -ChildPath modules -AdditionalChildPath devtoolbox)

$functionsToExport = @()
$aliasesToExport = @()
$typesToProcess = @()
$formatsToProcess = @()

Get-ChildItem -Recurse -Path $PWD\Export -Filter *.ps1 | ForEach-Object {
  # Load functions into scope
  . $_.FullName
  $function = $_.BaseName
  $aliases = @((Get-Alias | Where-Object ResolvedCommandName -eq $_.BaseName).name) | Where-Object { $null -ne $_ }
  $msg = "Exporting $function"
  $functionsToExport += $function
  if ($aliases.Count -gt 0) {
    $msg += " -> { $($aliases -join ", ") }"
    $aliasesToExport += $aliases
  }
  Write-Verbose $msg
}

Get-ChildItem -Recurse -Path $PWD -Filter *.ps1xml | Where-Object {
  [xml]$type = Get-Content $_.FullName
  $type.Types -ne $null
} |ForEach-Object {
  $typesToProcess += Resolve-Path -Path $_.FullName -Relative
}

Get-ChildItem -Recurse -Path $PWD -Filter *.ps1xml | Where-Object {
  [xml]$format = Get-Content $_.FullName
  $format.Configuration.ViewDefinitions -ne $null
} | ForEach-Object {
  $formatsToProcess += Resolve-Path -Path $_.FullName -Relative
}

$module = (Get-ChildItem *.psd1)
Update-Manifest -Path $module.FullName -PropertyName FunctionsToExport -Value $functionsToExport
Update-Manifest -Path $module.FullName -PropertyName AliasesToExport -Value $AliasesToExport
Update-Manifest -Path $module.FullName -PropertyName TypesToProcess -Value $typesToProcess
Update-Manifest -Path $module.FullName -PropertyName FormatsToProcess -Value $formatsToProcess

# Change our directory back to the directory we original came from
Pop-Location