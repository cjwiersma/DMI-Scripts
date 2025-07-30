$users = Get-Content -path "C:\Collin\userstempleave.txt"

foreach ($user in $users) {
    write-host "Processing user: $user" -ForegroundColor Cyan
    
}