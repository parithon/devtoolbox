$Export = @(Get-ChildItem -Path $PSScriptRoot\export -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\private -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)

foreach ($import in @($Utils + $Private + $Export)) {
  try {
    . $import.FullName
  }
  catch {
    Write-Error -Message "Failed to import function $($import.BaseName): $_"
  }
}

$params = @{}
$foundAliases = @()
$availableAliases = Get-Alias
$Export.BaseName | ForEach-Object {
  $foundAliases += $availableAliases | Where-Object ResolvedCommandName -eq $_
}
if ($foundAliases -and $foundAliases.Count -gt 0) {
  $params.Add("Alias", $foundAliases.Name)
}

$VMHost = Get-VMHost -ErrorAction Stop
$LabPath = [string]::Empty
try {
  $LabPath = Join-Path -Path $VMHost.VirtualMachinePath -ChildPath ".labenvironments" -Resolve -ErrorAction Stop
}
catch {
  New-Item -Path $VMHost.VirtualMachinePath -Name ".labenvironments" -ItemType File -Force | Out-Null
  $LabPath = Join-Path -Path $VMHost.VirtualMachinePath -ChildPath ".labenvironments" -Resolve
}
if ($LabPath -eq [string]::Empty) {
  Write-Error "Could not get the lab environment configuration path." -ErrorAction Stop
}

Export-ModuleMember -Function $Export.BaseName @params
