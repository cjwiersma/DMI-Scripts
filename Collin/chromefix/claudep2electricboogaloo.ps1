$computers = Get-Content "G:\SysShare\Utilities\Collin\chromefix\computerlist.txt"

foreach ($computer in $computers) {
    Write-Host "Enabling WinRM on $computer"
    
    # Use PSEXEC to remotely enable WinRM
    .\PSEXEC.exe \\$computer -s powershell Enable-PSRemoting -Force
    
    # Enable Windows Firewall rules
    .\PSEXEC.exe \\$computer -s powershell "Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -Enabled True"
    
    # Configure WinRM trusted hosts
    .\PSEXEC.exe \\$computer -s powershell "Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force"
    
    # Start WinRM service
    .\PSEXEC.exe \\$computer -s powershell "Start-Service WinRM"
}