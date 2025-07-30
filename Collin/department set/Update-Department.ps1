function update-department {
    [parameter(Mandatory=$true)]
    param (
        [string]$NewDepartmentName,
        [string]$OuName
    )
    process {
        $OU = Get-ADOrganizationalUnit -Filter "Name -eq '$OuName'"
        foreach($user in Get-ADUser -Filter * -SearchBase $OU.DistinguishedName -Properties Department, DisplayName) {
            if ($user.Department -eq $NewDepartmentName) {
                Write-Host "User $($user.DisplayName) already has the department set to $NewDepartmentName"
                continue
            }
            Set-ADUser -Identity $user -Department $NewDepartmentName
            Write-Host "Updated department for user $($user.DisplayName) to $NewDepartmentName"
        }
    }
}

$name = Read-Host 'Enter the name of the new department'
$ouName = Read-Host 'Enter the name of the OU'
update-department -NewDepartmentName $name -OuName $ouName