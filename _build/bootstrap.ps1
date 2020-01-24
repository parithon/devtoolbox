using namespace Microsoft.PowerShell.Commands
[CmdletBinding()]
param(
    #
    [ValidateSet("CurrentUser", "AllUsers")]
    $Scope = "CurrentUser"
)
[ModuleSpecification[]]$RequiredModules = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName RequiredModules
$Policy = (Get-PSRepository PSGallery).InstallationPolicy
Set-PSRepository PSGallery -InstallationPolicy Trusted
try {
    # Import-LocalizedData will create an object with both MaximumVersion and RequiredVersion properties.
    # However, Install-Module can only have one or the other. See https://docs.microsoft.com/en-us/powershell/module/powershellget/install-module?view=powershell-5.1#parameters
    # We use 'RequiredVersion' so lets only include the module 'Name' and 'RequiredVersion'
    $RequiredModules | Select-Object Name, RequiredVersion | Install-Module -Scope $Scope -Repository PSGallery -SkipPublisherCheck -Verbose
} finally {
    Set-PSRepository PSGallery -InstallationPolicy $Policy
}
$RequiredModules | Import-Module
