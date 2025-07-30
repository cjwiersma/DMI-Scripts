Install-Module -Name ExchangeOnlineManagement -force
Import-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

Clear-Host

Function Script {

    # Get proxy and user mailbox addresses
    $Proxyaddress = Get-Content -Path "C:\Users\wiersmc1\PycharmProjects\pspspspsps\proxy sendas fullaccess\proxy"
    $Useraddress = Read-Host "Enter EXACT USER mailbox address"
    for ($i = 0; $i -lt $content1.Count; $i++){
        $user = $Useraddress
        $Proxy = $Proxyaddress[$i]
        # Add recipient permission
        Add-RecipientPermission "$Proxy" -AccessRights SendAs -Trustee "$User" -confirm:$false
        Add-MailboxPermission "$Proxy" -AccessRights FullAccess -User "$User" -InheritanceType All -confirm:$false
    }
    # Disconnect from EXO or re-run
    $RerunorDC = Read-Host "Re-run for another user? (y/n)"
    if ($RerunorDC -eq "y") {
        script
    } else {
        Write-Host
        Write-Host "Disconnecting from EXO..." -ForegroundColor red
        Write-Host
        Disconnect-ExchangeOnline -confirm:$false
    }
}


script