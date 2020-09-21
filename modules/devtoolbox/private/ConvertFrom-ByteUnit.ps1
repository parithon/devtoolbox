function ConvertFrom-ByteUnit {
  [OutputType([long])]
  param
  (
    [string]
    $Value
  )
  $_, [long]$num, $unit = ($Value | Select-String -Pattern "(\d+)(\w+)").Matches.Groups.Value
  switch ($unit) {
    'KB' {
      $num = ($num * 1KB)
    }
    'MB' {
      $num = ($num * 1MB)
    }
    'GB' {
      $num = ($num * 1GB)
    }
  }
  return $num
}