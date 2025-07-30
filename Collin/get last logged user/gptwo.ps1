# Function to test WinRM on remote computer
function Test-RemoteWinRM {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName
    )

    try {
        Test-WSMan -ComputerName $ComputerName -ErrorAction Stop
        Write-Host "WinRM is already enabled on $ComputerName" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "WinRM is not enabled on $ComputerName" -ForegroundColor Yellow
        return $false
    }
}

# Function to enable WinRM remotely using PSExec
function Enable-RemoteWinRM {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName
    )

    try {
        # Check if PSExec exists in the current directory or in PATH
        $psexecPath = ".\PsExec.exe"
        if (-not (Test-Path $psexecPath)) {
            $psexecPath = "psexec"
        }

        # Use PSExec to directly launch PowerShell with the required commands
        $result = & $psexecPath "\\$ComputerName" -s powershell.exe Enable-PSRemoting -Force
        $result = & $psexecPath "\\$ComputerName" -s powershell.exe Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force
        $result = & $psexecPath "\\$ComputerName" -s powershell.exe Start-Service WinRM
        $result = & $psexecPath "\\$ComputerName" -s powershell.exe Set-Service WinRM -StartupType Automatic
        $result = & $psexecPath "\\$ComputerName" -s powershell.exe winrm quickconfig -force

        # Test if WinRM is now accessible
        if (Test-RemoteWinRM -ComputerName $ComputerName) {
            Write-Host "Successfully enabled WinRM on $ComputerName using PSExec" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Failed to verify WinRM configuration" -ForegroundColor Red
            return $false
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Failed to enable WinRM on $ComputerName`: $errorMessage" -ForegroundColor Red
        return $false
    }
}

# Function to get logon events (Event ID 4624) from remote computer
function Get-RemoteLogonEvents {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        [Parameter(Mandatory=$false)]
        [int]$Hours = 8
    )

    try {
        # Define the remote script block
        $ScriptBlock = {
            param($HoursToCheck)

            # Calculate the start time (8 hours ago)
            $StartTime = (Get-Date).AddHours(-$HoursToCheck)

            # Retrieve events for the last 3 days to ensure we get all potential events (larger window)
            $allEvents = Get-WinEvent -FilterHashtable @{
                LogName = 'Security'
                Id = 4624
                StartTime = (Get-Date).AddDays(-3) # 3 days window to ensure we get all potential events
            } -ErrorAction Stop

            # Now filter the events for the last 8 hours
            $logonEvents = $allEvents | Where-Object { $_.TimeCreated -ge $StartTime }

            # Process the logon events
            $logonEvents | ForEach-Object {
                $EventXML = [xml]$_.ToXml()

                $LogonType = $EventXML.Event.EventData.Data | Where-Object { $_.Name -eq 'LogonType' } | Select-Object -ExpandProperty '#text'
                $TargetUserName = $EventXML.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' } | Select-Object -ExpandProperty '#text'
                $IpAddress = $EventXML.Event.EventData.Data | Where-Object { $_.Name -eq 'IpAddress' } | Select-Object -ExpandProperty '#text'
                $WorkstationName = $EventXML.Event.EventData.Data | Where-Object { $_.Name -eq 'WorkstationName' } | Select-Object -ExpandProperty '#text'

                [PSCustomObject]@{
                    TimeCreated = $_.TimeCreated
                    UserName = $TargetUserName
                    LogonType = $LogonType
                    IpAddress = $IpAddress
                    WorkstationName = $WorkstationName
                }
            }
        }

        # Invoke the script block remotely
        $logonEvents = Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $Hours

        # Export logon events to Excel file
        if ($logonEvents) {
            $date = Get-Date -Format "yyyy-MM-dd_HH-mm"
            $exportPath = "C:\logon_events_$ComputerName_$date.xlsx"
            $logonEvents | Export-Excel -Path $exportPath -AutoSize -Title "Logon Events" -WorksheetName "Events"
            Write-Host "Logon events exported to $exportPath" -ForegroundColor Green
        }
        else {
            Write-Host "No logon events found." -ForegroundColor Yellow
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Failed to retrieve logon events: $errorMessage" -ForegroundColor Red
    }
}

# Main script
$ComputerName = Read-Host "Enter the remote computer name"

# Check if WinRM is enabled on the remote computer
if (-not (Test-RemoteWinRM -ComputerName $ComputerName)) {
    Write-Host "Attempting to enable WinRM using PSExec..." -ForegroundColor Yellow
    Enable-RemoteWinRM -ComputerName $ComputerName
}

# Fetch logon events from the remote computer and export to Excel
Write-Host "Fetching logon events from the remote computer..."
Get-RemoteLogonEvents -ComputerName $ComputerName -Hours 8
