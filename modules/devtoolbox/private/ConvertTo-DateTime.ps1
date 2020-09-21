function ConvertTo-DateTime {
  [OutputType([DateTime])]
  param
  (
    [string]
    $Value
  )
  $createdDate = [DateTime]::MinValue
  if (-not ([DateTime]::TryParse($Value, [ref] $createdDate))) {
    $_, $num, $span = ($Value | Select-String -Pattern "(\d+) (\w+)").Matches.Groups.Value
    switch ($span) {
      'seconds' {
        $createdDate = [DateTime]::Now.AddSeconds(-$num)
      }
      'minutes' {
        $createdDate = [DateTime]::Now.AddMinutes(-$num)
      }
      'hours' {
        $createdDate = [DateTime]::Now.AddHours(-$num)
      }
      'days' {
        $createdDate = [DateTime]::Now.AddDays(-$num)
      }
      'weeks' {
        $createdDate = [DateTime]::Now.AddDays(-(7*$num))
      }
      'months' {
        $createdDate = [DateTime]::Now.AddMonths(-$num)
      }
      'years' {
        $createdDate = [DateTime]::Now.AddYears(-$num)
      }
    }
  }
  return $createdDate
}