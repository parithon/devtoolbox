function Invoke-Docker {
  <#
    .SYNOPSIS
    Invoke docker commands using aliases

    .PARAMETER Command
    The docker command you want to invoke. You can use the default commands or the following alises:
    - b   : docker build
    - c   : docker container
    - cs  : docker container start
    - cx  : docker container stop
    - i   : docker images
    - t   : docker tag
    - k   : docker kill
    - l   : docker logs
    - li  : docker login
    - lo  : docker logout
    - r   : docker run
    - rmc : docker container rm
    - p   : docker push
    - v   : docker volume
    - psa : docker ps -a

    .PARAMETER Parameters
    The docker command parameters.
  #>
  [Alias("d")]
  Param
  (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Command,
    [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true)]
    [string[]]$Parameters
  )

  $params = @($Parameters)

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
    "psa" { docker ps -a @params }
    default { docker $Command @params }
  }
}

Register-ArgumentCompleter -CommandName Invoke-Docker -ParameterName Command -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $cmds = Get-DockerCommand
  return $(if ($wordToComplete) { $cmds | Where-Object { $_ -like "$wordToComplete*" } } else { $cmds })
}

Register-ArgumentCompleter -CommandName Invoke-Docker -ParameterName Parameters -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $cmd = $fakeBoundParameters["Command"]
    switch ($cmd) {
      "rmi" {
        $imgs = Get-DockerImage -All | Select-Object *,@{n="HasTag";e={$_.Tag -ne "<None>"}} | Sort-Object -Property HasTag, Created -Descending
        return $(if ($wordToComplete) { $imgs.Name | Where-Object { $_ -like "$wordToComplete*" } } else { $imgs.Name } )
      }
    }
    $cmds = Get-DockerCommand $cmd
}