$server = read-host "server name"
$output = qwinsta /server:$server
$header = $output[0]
$activeLines = $output | Where-Object { $_ -match "Active" }
Write-Output $header
Write-Output $activeLines
$ID = Read-Host"ID of user you want to connect to"

mstsc.exe /v:$server /shadow:$ID /control /noConsentPrompt