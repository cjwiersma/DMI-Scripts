$user = $(write-host 'User: ' -ForegroundColor Yellow -NoNewline; Read-Host)
$comp = $(write-host 'Computer/Server: ' -ForegroundColor Yellow -NoNewline; read-host)
$path = "\\$comp\c$\Users\$user\AppData\Local\Microsoft\Outlook"
if (Test-Path -path $path) {
    remove-item -path $path -recurse -Force
    write-host "Path deleted" -ForegroundColor Green
} else {
    write-host "Path not found" -ForegroundColor Red
}
