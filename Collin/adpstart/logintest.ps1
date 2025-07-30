$startTime = [TimeSpan]::Parse("07:00:00")
$endTime = [TimeSpan]::Parse("08:00:00")
$currentTime = (Get-Date).TimeOfDay

if ($currentTime -ge $startTime -and $currentTime -le $endTime) {
    Start-Process "https://workforcenow.adp.com"
} else {
    Write-Output "The time is not between 7 AM and 8 AM."
}
