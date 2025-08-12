
Function add-sendfull {
    param ([Parameter (Mandatory = $True)] [string]$Proxyaddress, [string]$Useraddress)
    # Add recipient permission
    Add-recipientPermission -Identity "$Proxyaddress" -trustee "$Useraddress" -AccessRights SendAs -confirm:$false
    Add-MailboxPermission -Identity "$Proxyaddress" -User "$Useraddress" -AccessRights FullAccess -InheritanceType All -confirm:$false
}

Function add-send {
    param ([Parameter (Mandatory = $True)] [string]$Proxyaddress, [string]$Useraddress)
    # Add recipient permission
    Add-recipientPermission -Identity "$Proxyaddress" -trustee "$Useraddress" -AccessRights SendAs -confirm:$false
}

Function add-full {
    param ([Parameter (Mandatory = $True)] [string]$Proxyaddress, [string]$Useraddress)
    # Add recipient permission
    Add-MailboxPermission -Identity "$Proxyaddress" -User "$Useraddress" -AccessRights FullAccess -InheritanceType All -confirm:$false
}

Connect-ExchangeOnline

$Proxyaddress = Read-Host "Enter EXACT PROXY mailbox address"
$Useraddress = Read-Host "Enter EXACT USER mailbox address"
clear
$rerun = $FALSE

while ($rerun -eq $FALSE) {
        write-host "Proxy - $Proxyaddress"
        write-host "User - $Useraddress"
        write-host "------------------------"
        write-host "1. Full access to proxy"
        write-host "2. Send as to proxy"
        write-host "3. Both"
        write-host "X to exit"
        $selection = read-host ">"
    switch ($selection) {
    "1" {add-full $Proxyaddress $Useraddress}
    "2" {add-send $Proxyaddress $Useraddress}
    "3" {add-sendfull $Proxyaddress $Useraddress}
    "x" {$rerun = $TRUE}
    default {write-host "invalid selection"}
    }
}