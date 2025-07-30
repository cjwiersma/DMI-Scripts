# Path to your Excel file
$excelFilePath = "\\sys22\VOL1\SysShare\Utilities\Collin\remove 3.5\v35.xlsx"

# Import the Excel file and get the 'ComputerName' column
$computers = Import-Excel -Path $excelFilePath | Select-Object -ExpandProperty ComputerName

$scriptBlock = {
   Remove-Item -path "C:\Windows\Microsoft.NET\Framework\v3.5" -recurse -force
   Remove-Item -path "C:\Windows\Microsoft.NET\Framework64\v3.5" -recurse -force
}

Invoke-Command -ComputerName $computers -ScriptBlock $scriptBlock