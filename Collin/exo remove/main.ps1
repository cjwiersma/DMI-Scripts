$filepath = "C:\Users\wiersmc1\PycharmProjects\pspspspsps\exo remove\emails"
$useremail = Get-Content -Path $filepath
for ($i = 0; $i -lt $useremail.Count; $i++) {
	$userName = $useremail[$i]
    Remove-MailboxPermission -Identity $userName -User "kathy.ciesemier@dmicorp.com" -AccessRights FullAccess -InheritanceType All -Confirm:$false
}

#below adds above removes

$filepath = "C:\Users\wiersmc1\PycharmProjects\pspspspsps\proxy sendas fullaccess\exo remove\emails"
$useremail = Get-Content -Path $filepath
for ($i = 0; $i -lt $useremail.Count; $i++) {
    $userName = $useremail[$i]
    Add-MailboxPermission -Identity $userName -User "kathy.ciesemier@dmicorp.com" -AccessRights FullAccess -InheritanceType All -Confirm:$false -AutoMapping $false
}