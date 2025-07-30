$ouname = "OU Name"
$disname = Get-ADUser -Filter * -SearchBase $ouname -Properties displayname, department
foreach($user in $disname) {
    $newDepartment = "Department Name"
    Set-ADUser -Identity $user -Department $newDepartment
}