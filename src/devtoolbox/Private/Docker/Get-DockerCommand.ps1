function Get-DockerCommand {
  [CmdletBinding(DefaultParameterSetName="None")]
  param (
    [Parameter(Position = 0)]
    [string]
    $Command,
    [Parameter(ParameterSetName="All")]
    [Alias("a")]
    [switch]
    $All,
    [Parameter(ParameterSetName="Management")]
    [Alias("m")]
    [switch]
    $ManagementOnly
  )

  $help = $(if ($Command) { docker $Command --help } else { docker --help })

  $mgmtCmdLineNumber = ($help | Select-String -Pattern "^Management Commands:").LineNumber
  $cmdLineNumber = ($help | Select-String -Pattern "^Commands:").LineNumber

  if ($null -eq $cmdLineNumber) {
    return $null
  }

  if ($null -ne $mgmtCmdLineNumber) {
    $mgmtCmdLines = ($help | Select-Object -Skip $mgmtCmdLineNumber -First ($cmdLineNumber - $mgmtCmdLineNumber - 2)).TrimStart()
  }

  $cmdLines = ($help | Select-Object -Skip $cmdLineNumber -First ($help.Count - $cmdLineNumber - 2)).TrimStart()

  $mgmtCmds = ($mgmtCmdLines | Select-String -Pattern "^[^ ]+").Matches.Value
  $cmds = ($cmdLines | Select-String -Pattern "^[^ ]+").Matches.Value

  if ($PSCmdlet.ParameterSetName -eq "All") {
    $retval = @($mgmtCmds + $cmds)
  }
  elseif ($PSCmdlet.ParameterSetName -eq "ManagementOnly") {
    $retval = $mgmtCmds
  }
  else {
    $retval = $cmds
  }
  
  $retval
}