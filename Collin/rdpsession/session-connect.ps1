$server = $(write-host "Server\PC Name: " -ForegroundColor Yellow -NoNewLine; Read-Host)
$output = qwinsta /server:$server
$header = $output[0]
$activeLines = $output | Where-Object { $_ -match "Active" }
Write-Output $header
Write-Output $activeLines
$ID =  $(write-host "ID: " -ForegroundColor Yellow -NoNewLine; Read-Host)

mstsc.exe /v:$server /shadow:$ID /control /f