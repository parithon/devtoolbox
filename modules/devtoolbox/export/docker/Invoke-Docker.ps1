Function Invoke-Docker {
  [Alias("d")]
  Param
  (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Command,
    [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true)]
    [string[]]$Parameters
  )

  $params = @()
  $params += $Parameters

  switch ($Command) {
    "b" { docker build @params }
    "c" { docker container @params }
    "cs" { docker container start @params }
    "cx" { docker container stop @params }
    "i" { docker images @params }
    "t" { docker tag @params }
    "k" { docker kill @params }
    "l" { docker logs @params }
    "li" { docker login @params }
    "lo" { docker logout @params }
    "r" { docker run @params  }
    "rmc" { docker container rm @params }
    "p" { docker push @params }
    "v" { docker volume @params }
    default { docker $Command @params }
  }
}

Function Get-DockerCommands {
  param(
    [string]$Command
  )
  $help = $(if ($Command) { docker.exe $Command --help } else { docker.exe --help }) | Select-String -Pattern "^\s{2}\w+"
  $cmds = @()
  for ($i = 0; $i -lt $help.Count; $i++) {
    $cmdline = $help[$i].Line.Trim()
    $cmds += $cmdline.Substring(0, $cmdline.IndexOf(" "))
  }
  return $cmds | Sort-Object
}

Register-ArgumentCompleter -CommandName Invoke-Docker -ParameterName Command -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $cmds = Get-DockerCommands
  return $(if ($wordToComplete) { $cmds | Where-Object { $_ -like "$wordToComplete*" } } else { $cmds })
}

Register-ArgumentCompleter -CommandName Invoke-Docker -ParameterName Parameters -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $cmd = $fakeBoundParameters["Command"]
  $ast = $commandAst.CommandElements | Where-Object Value -EQ $cmd
  $subcmdidx = $commandAst.CommandElements.IndexOf($ast)
  $subcmd = $commandAst.CommandElements[$subcmdidx + 1].Value

  switch ($cmd) {
    "b" { $cmd = "build" }
    "c" { $cmd = "container" }
    "cs" { $cmd = "container" }
    "cx" { $cmd = "container" }
    "i" { $cmd = "images" }
    "t" { $cmd = "tag" }
    "k" { $cmd = "kill" }
    "l" { $cmd = "logs" }
    "li" { $cmd = "login" }
    "lo" { $cmd = "logout" }
    "r" { $cmd = "run" }
    "rmc" { $cmd = "container" }
    "p" { $cmd = "push" }
    "v" { $cmd = "volume" }
  }

  if ((-not $subcmd -or $subcmd -eq $wordToComplete) -and (Get-DockerCommands) -contains $cmd) {
    $cmds = Get-DockerCommands $cmd
    $results = $(if ($wordToComplete) { $cmds | Where-Object { $_ -like "$wordToComplete*" } } else { $cmds })
    if ($results) { return $results }
  }

  if ($cmd -eq "container" -or $cmd -eq "rmc" -or $cmd -eq "rm") {
    $containers = Get-DockerContainer | Select-Object -ExpandProperty Name
    return $containers
  }

  if ($subcmd -ne "ls" -or $subcmd -ne "build" -or $subcmd -ne "import") {
    $images = Get-DockerImage | Select-Object Repository,ImageId,Tag | ForEach-Object {$image = $_;$_.Tag | Select-Object @{n="ImageId";e={$image.Imageid}},@{n="RepoTag";e={$image.Repository+":"+$_}}}
    $options = @()
    $options += $images | Where-Object {$_.RepoTag -ne "<none>:<none>"} | Select-Object -ExpandProperty RepoTag
    $options += $images | Where-Object {$_.RepoTag -eq "<none>:<none>"} | Select-Object -ExpandProperty ImageId
    $options = $options | Where-Object {-not ($commandAst.CommandElements | Select-Object -ExpandProperty Value).Contains($_)}
    return $options
  }
}
