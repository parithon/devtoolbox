Function Get-DockerContainer {
  [CmdletBinding()]
  [Alias("gdc")]
  param(
    # The container ID
    [Parameter()]
    [string]
    $Identity = "*"
  )

  $containerIds = docker.exe container ls -a -q
  if (-not $containerIds) {
    Write-Warning "No containers currently exist."
    return
  }

  $containerJSON = docker.exe inspect $containerIds | ConvertFrom-Json

  $containers = $containerJSON | ForEach-Object {
    $obj = [PSCustomObject]@{
      PSTypeName = "Docker.Container"
      Id = $_.Id
      Created = [DateTimeOffset]::Parse($_.Created+"-0000").LocalDateTime
      Path = $_.Path
      Args = $_.Args
      State = @{
        PSTypeName = "Docker.Container.State"
        Status = $_.State.Status
        Running =[bool]$_.State.Running
        Paused = [bool]$_.State.Paused
        Restarting = [bool]$_.State.Restarting
        OOMKilled = [bool]$_.State.OOMKilled
        Dead = [bool]$_.State.Dead
        Pid = [int]$_.State.Pid
        ExitCode = [int]$_.State.ExitCode
        Error = $_.State.Error
        StartedAt = [DateTimeOffset]::Parse($_.State.StartedAt+"-0000").LocalDateTime
        FinishedAt = [DateTimeOffset]::Parse($_.State.FinishedAt+"-0000").LocalDateTime
      }
      ImageId = $_.Image
      Names = $_.Name.Substring(1)
      RestartCount = $_.RestartCount
      Platform = $_.Platform
      Mounts = $_.Mounts
      Config = $_.Config
      NetworkSettings = $_.NetworkSettings
    }
    
    $obj.Mounts | ForEach-Object {
      $_.PSObject.TypeNames.Clear()
      $_.PSObject.TypeNames.Add("Docker.Container.Mount")
    }

    $obj.Config.PSObject.TypeNames.Clear()
    $obj.Config.PSObject.TypeNames.Add("Docker.Container.Config")

    $obj.NetworkSettings.PSObject.TypeNames.Clear()
    $obj.NetworkSettings.PSObject.TypeNames.Add("Docker.Contianer.NetworkSetting")

    return $obj
  }

  if ($containers | Where-Object Id -Like "$Identity*") {
    $containers | Where-Object Id -Like "$Identity*"
  } else { 
    $containers | Where-Object Names -Like "$Identity*"
  }
}