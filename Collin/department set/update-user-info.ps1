# This script is designed to update user information in Active Directory
# It allows the user to change the name or department of a user
# It prompts the user for confirmation before making any changes
# written by: Collin Wiersma

#This function updates a user's first name, last name, or display name in Active Directory based on techs input.
function set-name {
    [parameter(Mandatory=$true)]
    param (
        [string]$name
    )
    $user = Get-ADUser -filter "name -like '$name'" -properties givenname, surname, displayname
    write-host "which would you like to change?" -ForegroundColor Yellow
    write-host "
    1. First Name $($user.givenname)
    2. Last Name $($user.surname)
    3. Display Name $($user.displayname)
    4. Exit
    "
    $choice = read-host '1/2/3/4'
    switch ($choice) {
        1 {
            $newName = read-host 'Enter the new first name'
            Set-ADUser -Identity $user -GivenName $newName
            Write-host "First name updated to $newName"
        }
        2 {
            $newName = read-host 'Enter the new last name'
            Set-ADUser -Identity $user -Surname $newName
            Write-host "Last name updated to $newName"
        }
        3 {
            $newName = read-host 'Enter the new display name'
            Set-ADUser -Identity $user -DisplayName $newName
            Write-host "Display name updated to $newName"
        }
        4 {
            return
        }
        default {
            Write-host "Invalid choice. Please select 1, 2, or 3."
        }
    }
}

# Function to update department
# This function allows the tech to update the department for all users in a specific OU or for a specific user
function update-department {
    [parameter(Mandatory=$true)]
    param (
        [string]$NewDepartmentName,
        [string]$OuName,
        [string]$name
    )
    write-host "1. Update department for all users in the OU"
    write-host "2. Update department for a specific user"
    write-host "3. Exit"
    $choice = read-host '1/2/3'
    switch ($choice) {
        1 {
            write-host "Updating department for all users in the OU"
            $OU = Get-ADOrganizationalUnit -Filter "Name -like '$OuName'" -properties distinguishedname
            foreach($user in Get-ADUser -Filter * -SearchBase $OU.DistinguishedName -Properties Department, DisplayName) {
                if ($user.Department -eq $NewDepartmentName) {
                    Write-Host "User $($user.DisplayName) already has the department set to $NewDepartmentName"
                    continue
                }
                Set-ADUser -Identity $user -Department $NewDepartmentName
                Write-Host "Updated department for user $($user.DisplayName) to $NewDepartmentName"
            }
        }
        2 {
            write-host "Updating department for a specific user"
            $user = Get-ADUser -filter "name -like '$name'" -properties department
            write-host "Current department: $($user.department)"
            Set-ADUser -Identity $user -Department $NewDepartmentName
            Write-host "Department updated to $NewDepartmentName"
        }
        3 {
            return
        }
    }
}

# Function to get users computers
# This function retrieves the computer names for a specific user and allows the tech to update them
function set-computer {
    [parameter(Mandatory=$true)]
    param (
        [string]$name
    )
    $user = Get-ADUser -filter "name -like '$name'" -properties displayname, Pager, MobilePhone, HomePhone, Fax
    write-host "which would you like to change for $($user.displayname)?" -ForegroundColor Yellow
    write-host "1. $($user.HomePhone)"
    write-host "2. $($user.Pager)"
    write-host "3. $($user.MobilePhone)"
    write-host "4. $($user.Fax)"
    write-host "5. Exit"
    $choice = read-host '1/2/3/4/5'
    switch ($choice) {
        1 {
            $newName = read-host 'Enter the new home phone number'
            Set-ADUser -Identity $user -HomePhone $newName
            Write-host "Home phone number updated to $newName"
        }
        2 {
            $newName = read-host 'Enter the new pager number'
            Set-ADUser -Identity $user -Pager $newName
            Write-host "Pager number updated to $newName"
        }
        3 {
            $newName = read-host 'Enter the new mobile number'
            Set-ADUser -Identity $user -MobilePhone $newName
            Write-host "Mobile number updated to $newName"
        }
        4 {
            $newName = read-host 'Enter the new fax number'
            Set-ADUser -Identity $user -Fax $newName
            Write-host "Fax number updated to $newName"
        }
        5 {
            return
        }
        default {
            Write-host "Invalid choice. Please select 1, 2, 3, or 4."
        }
    }
    
}

#function to update users desklocation
# This function retrieves the desk location for a specific user and allows the tech to update it
function set-desklocation {
    [parameter(Mandatory=$true)]
    param (
        [string]$name
    )
    $user = Get-ADUser -filter "name -like '$name'" -properties homepage
    write-host "Current desk location: $($user.homepage)"
    $newLocation = read-host 'Enter the new desk location'
    Set-ADUser -Identity $user -HomePage $newLocation
    Write-host "Desk location updated to $newLocation"
    
}

# Function to update user information
# This function prompts the Tech for confirmation and then allows them to update the user's name or department
function update-user-info {
    [parameter(Mandatory=$true)]
    param (
        [string]$name
    )
    clear-host
    $user = Get-ADUser -filter "name -like '$name'" -properties samaccountname, displayname, department
    write-host "Is this the correct user?" -ForegroundColor Yellow
    write-host "
    $($user.displayname)
    $($user.samaccountname)
    $($user.department)
    " 
    $confirm = read-host 'y/n' 
    if (!($confirm -eq 'y')) {
        Clear-Host
        Write-host "Please enter the correct name"
        $retry = read-host 'please enter the users name'
        user-info-update -name $retry
    } else {
        clear-host
        Write-host "Edit the user information for " -NoNewline -ForegroundColor Yellow
        write-host "$($user.displayname)" -ForegroundColor Green
        write-host '1. Name Change'
        write-host "2. Department Change"
        write-host "3. Update Computer Name"
        write-host "4. Update Desk Location"
        write-host "5. Exit"
        $choice = read-host '1/2/3/4/5'
        switch ($choice) {
            1 {
                clear-host
                set-name -name $user.displayname
            }
            2 {
                clear-host
                update-department -NewDepartmentName $user.department -OuName $user.department -name $user.displayname
            }
            3 {
                clear-host
                set-computer -name $user.displayname
            }
            4 {
                clear-host
                set-desklocation -name $user.displayname
            }
            5 {
                exit
            }
        }
    }
}

# Main script execution
$un = read-host 'Enter the name of the user'
update-user-info -name $un