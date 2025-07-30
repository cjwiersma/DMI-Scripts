# this is to automatically delete AD users from the Terminated Employees OU
#author: collin wiersma

$se = @()
# add 7am to 8 am time frame of deletion
foreach($user in Get-ADUser -Filter * -SearchBase 'OU=Terminated Employees,DC=DMICorp,DC=com' -Properties DisplayName, lastlogondate, enabled) {
    $deletedate = Get-Date
    $daysinactive = ($deletedate - $user.lastlogondate).Days
    if ($daysinactive -ge 30 -and $user.enabled -eq $false) {
        #Remove-ADUser -Identity $user -Confirm:$false
        $LOG = "User $($user.DisplayName) has been deleted from AD on $($deletedate)."
        $LOG | set-content -Path "\\dmi2\systems\IT Security & Compliance\Audit Review\Terminated OU Deletions\$($user.samaccountname).txt"
    } elseif ($user.enabled -eq $true) {
        $se += $user
    }
} if (!($se.Count -eq 0)) {
    Write-Host "The following users are still enabled in the Terminated Employees OU:" -ForegroundColor Yellow
    foreach ($user in $se) {
        write-host $user.displayname -ForegroundColor Red
        read-host "Press Enter to continue"
    }
}