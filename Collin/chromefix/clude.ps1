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

            # Create PSSession with current credentials
            $session = New-PSSession -ComputerName $computer -ErrorAction Stop

            # Enable WinRM
            Invoke-Command -Session $session -ScriptBlock {
                # Enable WinRM service
                Set-Service -Name WinRM -StartupType Automatic
                Start-Service -Name WinRM

                # Configure WinRM
                winrm quickconfig -quiet
                Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force
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
$computers = Get-Content -Path "G:\SysShare\Utilities\Collin\chromefix\computerlist.txt"  # One computer name per line
$results = Enable-RemoteWinRM -ComputerList $computers #-Credential $cred

# Display results
Write-Host "`nSuccessful deployments:"
$results.Successful | ForEach-Object { Write-Host "- $_" }

Write-Host "`nFailed deployments:"
$results.Failed | ForEach-Object { 
    Write-Host "- $($_.Computer): $($_.Error)" 
}