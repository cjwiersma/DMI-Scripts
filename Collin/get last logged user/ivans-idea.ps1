$users = Get-ADUser -Filter *

$serverPaths = @(
    "\\DMI4\HOME\",
    "\\DMI9\HOME\",
    "\\DMI11\HOME\"
)

$IncludePattern = "PC\S*"

$results = @()


foreach ($user in $users) {
    $samAccountNames = $user.SamAccountName
    $displayNames = $user.Name

    foreach ($serverPath in $serverPaths) {
        $userPath = Join-Path $serverPath -ChildPath "$samAccountNames\lastlogoninfo.txt"

        try {
            $fileExists = Test-Path $userPath -ErrorAction Stop

            if ($fileExists) {
                $fileContent = (Get-Content $userPath -Tail 1 -ErrorAction SilentlyContinue)

                if ($line -match $IncludePattern) {
                    $lastLine = $fileContent | Select-Object -Last 1
                    $results += [PSCustomObject]@{
                        name = $displayNames
                        Username = $samAccountNames
                        Server = $serverPath
                        LastLine = $lastLine
                    }
                } else {
                    Write-Host "Excluding user $displayNames at $userPath due to excluded pattern"
                }
            }
        }
        catch {
            $results += [PSCustomObject]@{
                Name = $displayNames
                Username = $samAccountNames
                Server = $serverPath
                Exists = $false
                LastLine = "Error reading file"
            }
        }
    }
}
$results | Export-Csv "UserFolderCheck_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
$results | Format-Table -AutoSize