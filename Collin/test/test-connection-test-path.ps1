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

$exists = @()
$online = @()
$offline = @()

$excelFilePath = $(write-host "Path to excel file: " -ForegroundColor Yellow -NoNewLine; Read-Host)


$pluginOutputColumnName = "Plugin Output"  
$computername = "NetBIOS Name"

$excelData = Import-Excel -Path $excelFilePath

foreach ($row in $excelData) {
    $pluginOutput = $row.$pluginOutputColumnName
    $computer = $row.$computername
    $trimmedNames = $computer | ForEach-Object {
        $_ -replace "DMI_NT\\", ""
    }
    if ($pluginOutput) {
        $path = Extract-Path -pluginOutput $pluginOutput
        $pathtrim = $path | ForEach-Object {
            $_ -replace "C:\\", ""
        }
        $removalpath = "\\$trimmedNames\c$\$pathtrim"
        if (test-connection -ComputerName $trimmedNames -Count 1 -Quiet) {
            $removalpath = "\\$trimmedNames\c$\$pathtrim"
            if (test-path $removalpath) {
                    $exists += $trimmedNames
                } else {
                    $online += $trimmedNames
                }
            } else {
                $offline += $trimmedNames
            }
        }
    }

$(write-host "online computers with vulnerability: " -ForegroundColor Green; $exists -join ", ")
$(write-host "online computers w/o vulnerability: " -ForegroundColor yellow; $online -join ", ")
$(write-host "offline computers: " -ForegroundColor Red; $offline -join ", ")