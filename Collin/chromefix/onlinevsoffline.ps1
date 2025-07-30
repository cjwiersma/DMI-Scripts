# Define the list of computers to ping
$excelFilePath = "\\sys22\VOL1\SysShare\Utilities\Collin\chromefix\chrome remove.xlsx"

$computers = Import-Excel -Path $excelFilePath | Select-Object -ExpandProperty DeviceName


# Create arrays to store online and offline computers
$onlineComputers = @()
$offlineComputers = @()

# Loop through each computer and test the connection
foreach ($computer in $computers) {
    if (Test-Connection -ComputerName $computer -Quiet -Count 1 -ErrorAction SilentlyContinue) {
        $onlineComputers += $computer
    } else {
        $offlineComputers += $computer
    }
}

# Output the results
Write-Host "Online Computers:"
$onlineComputers

Write-Host "Offline Computers:"
$offlineComputers
