Import-Module ImportExcel

# Function to extract path from plugin output
function Extract-Path {
    param (
        [string]$pluginOutput
    )
    
    $pattern = "Path\s+:\s+(.*?)\s+Installed version"
    $match = [regex]::Match($pluginOutput, $pattern)
    
    if ($match.Success) {
        return $match.Groups[1].Value.Trim()
    } else {
        return "Path not found"
    }
}

$vuln = $(write-host "Vulnerability Name: " -ForegroundColor Yellow -NoNewLine; Read-Host)
# Specify the Excel file path
$excelFilePath = $(write-host "Path to excel file: " -ForegroundColor Yellow -NoNewLine; Read-Host)

# Specify column names - adjust these to match your Excel structure
$pluginOutputColumnName = "Plugin Output"  # Column containing plugin output
$computername = "DNS Name"  # Column containing computer names

$results = @()

# Read the Excel file
$excelData = Import-Excel -Path $excelFilePath
# Process each row and extract paths
foreach ($row in $excelData) {
    $pluginOutput = $row.$pluginOutputColumnName
    $computer = $row.$computername
    $trimmedNames = $computer | ForEach-Object {
        $_ -replace ".dmicorp.com", ""
    }
    if ($pluginOutput) {
        # Extract path
        $path = Extract-Path -pluginOutput $pluginOutput
        $pathtrim = $path | ForEach-Object {
            $_ -replace "C:\\", ""
        }
        $removalpath = "\\$trimmedNames\c$\$pathtrim"
        if (!(Test-Path $removalpath)) {
            if (!(test-connection $trimmedNames -count 1 -quiet)) {
                $results += [pscustomobject]@{
                    ComputerName = $trimmedNames
                    Path = $removalpath
                    Status = "Offline"
                }
            } else {
                $results += [pscustomobject]@{
                    ComputerName = $trimmedNames
                    Path = $removalpath
                    Status = "Not Found"
                }
            }
        } else {
            remove-item -Path $removalpath -Recurse -Force
            if (!(Test-Path $removalpath)) {
                $results += [pscustomobject]@{
                    ComputerName = $trimmedNames
                    Path = $removalpath
                    Status = "Success"
                }
            } else {
                $results += [pscustomobject]@{
                    ComputerName = $trimmedNames
                    Path = $removalpath
                    Status = "Failed"
                }
            }
        }
    }
}
# Export results to a CSV file
$results | Export-Csv -Path "results_for_$vuln.csv" -NoTypeInformation

Write-Host "Results exported to results.csv" -ForegroundColor Green