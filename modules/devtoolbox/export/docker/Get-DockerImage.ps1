Function Get-DockerImage {
  [Alias("gdi")]
  param(
    # The Image ID
    [Parameter()]
    [Alias("Id")]
    [string]
    $ImageId = "*"
  )

  $imageIds = docker.exe images -a -q
  if (-not $imageIds) {
    Write-Warning "No images have been pulled."
    return
  }

  $imageJSON = docker.exe inspect ($imageIds) | ConvertFrom-Json | Select-Object -Property * -Unique

  $imageJSON | ForEach-Object {
    $obj = [PSCustomObject]@{
      PSTypeName = "Docker.Image"
      Id = $_.Id
      RepoTags = $_.RepoTags
      RepoDigests = $_.RepoDigests
      Repository = $_.RepoTags[0].Split(":")[0]
      Tag = $_.RepoTags | ForEach-Object { $_.Split(":")[1] } | Sort-Object -Descending
      Parent = $_.Parent
      Comment = $_.Comment
      Created = [DateTimeOffset]::Parse($_.Created).LocalDateTime
      Container = $_.Container
      ContainerConfig = $_.ContainerConfig
      DockerVersion = $_.DockerVersion
      Author = $_.Author
      Config = $_.Config
      Architecture = $_.Architecture
      OS = $_.Os
      Size = $_.Size
      VirtualSize = $_.VirtualSize
      GraphDriver = $_.GraphDriver
      RootFS = $_.RootFS
      Metadata = $_.Metadata
    }

    $obj.ContainerConfig.PSObject.TypeNames.Clear()
    $obj.ContainerConfig.PSObject.TypeNames.Add("Docker.Config")

    $obj.Config.PSObject.TypeNames.Clear()
    $obj.Config.PSObject.TypeNames.Add("Docker.Config")

    $obj
  } | Where-Object Id -Like "$ImageId*"
} 