# Function to enable WinRM on remote computers
function Enable-RemoteWinRM {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerList

    )

    # Results tracking
    $results = @{
        Successful = @()
        Failed = @()
    }

    foreach ($computer in $ComputerList) {
        try {
            Write-Host "Processing $computer..."

            # Test if computer is reachable
            if (-not (Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
                throw "Computer is not reachable"
            }
            Write-Host "psexec WinRM on $computer"
            # Use PSEXEC to remotely enable WinRM
            .\PSEXEC.exe \\$computer -s powershell Enable-PSRemoting -Force
            # Enable Windows Firewall rules
            .\PSEXEC.exe \\$computer -s powershell "Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -Enabled True"
            # Configure WinRM trusted hosts
            .\PSEXEC.exe \\$computer -s powershell "Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force"
            # Start WinRM service
            .\PSEXEC.exe \\$computer -s powershell "Start-Service WinRM"

            $session = New-PSSession -ComputerName $computer -ErrorAction Stop

            Write-Host "invoke command WinRM $computer"
            Invoke-Command -Session $session -ScriptBlock {
                # Enable WinRM service
                Set-Service -Name WinRM -StartupType Automatic
                Start-Service -Name WinRM

                # Configure WinRM
                winrm quickconfig -quiet
                Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force

		        Start-Process -FilePath "\\dmi2\systems\Helpdesk\CMS Upgrade\SetupSup_QA20.exe" -ArgumentList "/silent", "/install" -Wait
                Start-Process -FilePath "\\dmi2\systems\Helpdesk\CMS Upgrade\SetupTE_QA20.exe" -ArgumentList -ArgumentList "/silent", "/install" -Wait
            }

            $results.Successful += $computer
            Remove-PSSession $session
        }
        catch {
            $results.Failed += @{
                Computer = $computer
                Error = $_.Exception.Message
            }
            Write-Warning "Failed to process $computer. Error: $($_.Exception.Message)"
        }
    }

    # Return results
    return $results
}

# Usage example:
$computers = Get-Content -Path "C:\Users\wiersmc1\PycharmProjects\pspspspsps\cmsremote\computers"  # One computer name per line
$results = Enable-RemoteWinRM -ComputerList $computers

# Display results
Write-Host "`nSuccessful deployments:"
$results.Successful | ForEach-Object { Write-Host "- $_" }

Write-Host "`nFailed deployments:"
$results.Failed | ForEach-Object {
    Write-Host "- $($_.Computer): $($_.Error)"
}