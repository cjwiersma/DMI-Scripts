function Test-PathWithTimeout {
    param (
        [string]$Path,
        [int]$TimeoutSeconds = 10
    )

    $jobScript = {
        param($Path)
        Test-Path $Path -ErrorAction Stop
    }

    $job = Start-Job -ScriptBlock $jobScript -ArgumentList $Path

    if (Wait-Job $job -Timeout $TimeoutSeconds) {
        $result = Receive-Job $job
        Remove-Job $job
        return $result
    } else {
        Remove-Job $job -Force
        throw "Timeout after $TimeoutSeconds seconds while accessing $Path"
    }
}

function Get-ContentWithTimeout {
    param (
        [string]$Path,
        [int]$TimeoutSeconds = 10
    )

    $jobScript = {
        param($Path)
        Get-Content $Path -Tail 1 -ErrorAction Stop
    }

    $job = Start-Job -ScriptBlock $jobScript -ArgumentList $Path

    if (Wait-Job $job -Timeout $TimeoutSeconds) {
        $result = Receive-Job $job
        Remove-Job $job
        return $result
    } else {
        Remove-Job $job -Force
        throw "Timeout after $TimeoutSeconds seconds while reading $Path"
    }
}

$batchSize = 100
$users = Get-ADUser -Filter *
$totalUsers = $users.Count
$processedCount = 0

$serverPaths = @(
    "\\DMI4\HOME\",
    "\\DMI9\HOME\",
    "\\DMI11\HOME\"
)
clear
$word = Read-Host 'What kind of report would you like to make?
-------------------------------------------
For an AVD report type EPHTTS
For an In-Office report type PC
If you want to exit press ctrl + c
>'
$IncludePattern = "$word\S*"
$results = @()

# Create a single output file at the start
$date = Get-Date -Format 'yyyyMMdd_HHmmss'
$outputPath = "\\sys22\vol1\sysshare\reports\LastLogonInfo_$date.csv"

Write-Host "Total users to process: $totalUsers" -ForegroundColor Cyan
Write-Host "Results will be saved to: $outputPath" -ForegroundColor Yellow

for ($i = 0; $i -lt $users.Count; $i += $batchSize) {
    $userBatch = $users | Select-Object -Skip $i -First $batchSize

    Write-Host "`nProcessing batch $([Math]::Floor($i/$batchSize) + 1) (Users $($i + 1) to $([Math]::Min($i + $batchSize, $totalUsers)))" -ForegroundColor Yellow

    foreach ($user in $userBatch) {
        $samAccountNames = $user.SamAccountName
        $displayNames = $user.Name
        $processedCount++

        foreach ($serverPath in $serverPaths) {
            $userPath = Join-Path $serverPath -ChildPath "$samAccountNames\lastlogoninfo.txt"

            try {
                $fileExists = Test-PathWithTimeout -Path $userPath -TimeoutSeconds 10

                if ($fileExists) {
                    $fileContent = Get-ContentWithTimeout -Path $userPath -TimeoutSeconds 10

                    if ($fileContent -match $IncludePattern) {
                        $newResult = [PSCustomObject]@{
                            Name = $displayNames
                            Username = $samAccountNames
                            Server = $serverPath
                            LastLine = $fileContent
                            Status = "Success"
                        }
                        # Append the new result to the CSV file
                        $newResult | Export-Csv -Path $outputPath -NoTypeInformation -Append
                        Write-Host "Found match for user $displayNames on $serverPath" -ForegroundColor Green
                    }
                }
            }
            catch {
                $errorMessage = $_.Exception.Message
                Write-Warning "Error processing $userPath : $errorMessage"
                $newResult = [PSCustomObject]@{
                    Name = $displayNames
                    Username = $samAccountNames
                    Server = $serverPath
                    LastLine = "Error: $errorMessage"
                    Status = "Failed"
                }
                # Append the error result to the CSV file
                $newResult | Export-Csv -Path $outputPath -NoTypeInformation -Append
            }
        }

        $percentComplete = [math]::Round(($processedCount / $totalUsers) * 100, 2)
        Write-Progress -Activity "Processing Users" -Status "$percentComplete% Complete" -PercentComplete $percentComplete
    }
}

Write-Host "`nProcessing complete. All results have been saved to $outputPath" -ForegroundColor Cyan