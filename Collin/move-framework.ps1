$keepGoing = $true

$frameworkPath = test-path "C:\Windows\Microsoft.NET\Framework"
$DMILauncher = test-path "C:\Program Files (x86)\DMI"

$frameworkCopy = "Copy Framework"
$DMILauncherCopy = "Copy DMI Launcher"

write-host "Input computer to copy the framework to: " -ForegroundColor Yellow
$computerName = Read-Host

while ($keepGoing -eq $true) {

    Clear-Host
    Write-Host "`n      Welcome to the DMI Framework Copy Utility" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------" -ForegroundColor Yellow
    
    if (Test-Connection -ComputerName $computerName -Count 1 -ErrorAction SilentlyContinue) {
        write-host "Connection to $computerName successful." -ForegroundColor Green
    } else {
        write-host "Connection to $computerName failed. Please check the computer name and try again." -ForegroundColor Red
        $keepGoing = $false
        continue
    } if ($frameworkPath) {
        Write-Host "1. $frameworkCopy"
    } else {
        Write-Host "Framework not found on local machine" -ForegroundColor Red
    } if ($DMILauncher) {
        Write-Host "2. $DMILauncherCopy"
    } else {
        Write-Host "DMI Launcher not found on local machine" -ForegroundColor Red
    }
    Write-Host "3. Exit"
    $choice = Read-Host "Please select an option (1, 2, or 3)"

    switch ($choice) {
        1 {
            $valid = $false
            while ($valid -eq $false) {
                $frameworkPath1 = "C:\Windows\Microsoft.NET\Framework"
                $destinationPath = "\\$computerName\C$\Windows\Microsoft.NET"
                copy-item -Path $frameworkPath1 -Destination $destinationPath -Recurse -Force -ErrorAction SilentlyContinue
                $frameworkCopy = "Framework copied successfully"
                $valid = $true
            }
        }
        2 {
            $valid = $false
            while ($valid -eq $false) {
                $DMILauncherPath = "C:\Program Files (x86)\DMI"
                $destinationPath = "\\$computerName\C$\Program Files (x86)"
                copy-item -Path $DMILauncherPath -Destination $destinationPath -Recurse -Force -ErrorAction SilentlyContinue
                $DMILauncherCopy = "DMI Launcher copied successfully"
                $valid = $true
            }
        }
        3 {
            $restartChoice = read-host "do you want to restart the computer? (Y/N)"
            if ($restartChoice -eq "Y") {
                Restart-Computer -ComputerName $computerName -Force
                write-host "Restarting computer..." -ForegroundColor yellow
            } else {
                Write-Host "Exiting without restart." -ForegroundColor Yellow
            }
            $keepGoing = $false
        }
        default {
            Write-Host "Invalid choice, please try again." -ForegroundColor Yellow
        }
    }
}
