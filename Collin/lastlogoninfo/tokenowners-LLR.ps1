$users = Get-ADGroupMember -Identity S-1-5-21-1370651826-624977167-926709054-58614
$serverPaths = @(
    "\\DMI4\HOME\",
    "\\DMI9\HOME\",
    "\\DMI11\HOME\"
)

# Create a single output file at the start
$date = Get-Date -Format 'yyyyMMdd_HHmmss'
$outputPath = "\\sys22\vol1\sysshare\reports\LastLogonInfo_$date.csv"

foreach ($user in $users) {
    $samAccountNames = $user.SamAccountName
    $displayNames = $user.Name

    foreach ($serverPath in $serverPaths) {
        $userPath = Join-Path $serverPath -ChildPath "$samAccountNames\lastlogoninfo.txt"

        try {
            $fileExists = Test-Path -path $userPath

            if ($fileExists) {
                $fileContent = Get-Content -Path $userPath 

                # Join all lines into a single string with line breaks preserved
                $allLines = $fileContent -join "`n"

                $newResult = [PSCustomObject]@{
                    Name = $displayNames
                    Username = $samAccountNames
                    Server = $serverPath
                    LastLine = $allLines
                    Status = "Success"
                }
                # Append the new result to the CSV file
                $newResult | Export-Csv -Path $outputPath -NoTypeInformation -Append
                Write-Host "Found match for user $displayNames on $serverPath" -ForegroundColor Green
            
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
}


Write-Host "`nProcessing complete. All results have been saved to $outputPath" -ForegroundColor Cyan