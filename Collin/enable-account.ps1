<#
.DESCRIPTION
This script enables AD user accounts based on a JSON file that contains the user's start date.
This can be used as a jams job to run daily at 6am to enable accounts.
#>

$report = @()
$LOGPath = "\\sys22\VOL1\SysShare\Utilities\Collin\enable account test\EnabledUsers_$(Get-Date -Format 'yyyy-MM-dd').csv"

$ADaccounts = Get-ADUser -Filter 'enabled -eq $false' -SearchBase 'OU=Departments,DC=DMICorp,DC=com' -Properties distinguishedname, name, samaccountname
$Users = $ADaccounts | Where-Object { $_.distinguishedname -notmatch 'OU=Vendors,OU=Departments,DC=DMICorp,DC=com' -and $_.distinguishedname -notmatch 'OU=AZ Vendors,OU=Departments,DC=DMICorp,DC=com' -and $_.name -notmatch 'Template' }

foreach ($user in $Users) {
    $JSONPath = "\\sys22\VOL1\SysShare\Utilities\Users\$($user.samaccountname).json"
    Write-Host "Processing user: $($user.name)" -ForegroundColor Cyan
    $Obj = New-Object PSObject
    $Obj | Add-Member -MemberType NoteProperty -Name "User Name" -Value $user.name
    $Obj | Add-Member -MemberType NoteProperty -Name "Start Date" -Value $userData.startdate
    if (Test-Path $JSONPath) {
        $userData = Get-Content -Path $JSONPath | ConvertFrom-Json
        if ($userData.startdate -eq (Get-Date).ToString('yyyy-MM-dd')) {
            Write-Host "Found user: $($user.name) with start date matching today. Enabling account..."
            #Enable-ADAccount -Identity $user.samaccountname
            $Obj | Add-Member -MemberType NoteProperty -Name "Processed Date" -Value (Get-Date -Format yyyy-MM-dd)
            Write-Host "User $($user.name) has been enabled."
        } else {
            $Obj | Add-Member -MemberType NoteProperty -Name "Processed Date" -Value "User $($user.name) is already enabled on $($userData.startdate)."
            Write-Host "User $($user.name) is already enabled on $($userData.startdate)."
        }
    } else {
        Write-Host "No JSON file found for user: $($user.name). Skipping..."
        Write-Host "Check $JSONPath for the user's JSON file or search jira for new hire ticket" -ForegroundColor Red
        $Obj | Add-Member -MemberType NoteProperty -Name "Processed Date" -Value "file not found -- check jira or $JSONPath"
    }
    $report+= $Obj
}
$report | format-table
$report | export-csv -path $LOGPath
