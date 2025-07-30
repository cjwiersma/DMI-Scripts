# Function to handle timeouts
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

$IncludePattern = "PC\S*"
$results = @()

Write-Host "Total users to process: $totalUsers" -ForegroundColor Cyan

# Process users in batches
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
                        $results += [PSCustomObject]@{
                            Name = $displayNames
                            Username = $samAccountNames
                            Server = $serverPath
                            LastLine = $fileContent
                            Status = "Success"
                        }
                        Write-Host "Found match for user $displayNames on $serverPath" -ForegroundColor Green
                    }
                }
            }
            catch {
                $errorMessage = $_.Exception.Message
                Write-Warning "Error processing $userPath : $errorMessage"
                $results += [PSCustomObject]@{
                    Name = $displayNames
                    Username = $samAccountNames
                    Server = $serverPath
                    LastLine = "Error: $errorMessage"
                    Status = "Failed"
                }
            }
        }

        # Show progress after each user
        $percentComplete = [math]::Round(($processedCount / $totalUsers) * 100, 2)
        Write-Progress -Activity "Processing Users" -Status "$percentComplete% Complete" -PercentComplete $percentComplete
    }

    # Export intermediate results after each batch
    $date = Get-Date -Format 'yyyyMMdd_HHmmss'
    $outputPath = "UserFolderCheck_$date.csv"
    $results | Export-Csv $outputPath -NoTypeInformation
    Write-Host "Intermediate results exported to $outputPath" -ForegroundColor Cyan
}

# Final export
$finalDate = Get-Date -Format 'yyyyMMdd_HHmmss'
$finalOutputPath = "UserFolderCheck_FINAL_$finalDate.csv"
$results | Export-Csv $finalOutputPath -NoTypeInformation

Write-Host "`nProcessing complete. Final results exported to $finalOutputPath" -ForegroundColor Cyan
$results | Format-Table -AutoSize