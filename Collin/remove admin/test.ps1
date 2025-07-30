# Define the path to the text file
$filePath = "C:\Users\wiersmc1\PycharmProjects\pspspspsps\names"
$filePath2 = "C:\Users\wiersmc1\PycharmProjects\pspspspsps\pc"
# Read the content of the file
$content1 = Get-Content -Path $filePath
$content2 = Get-Content -Path $filePath2
# Loop through each line
for ($i = 0; $i -lt $content1.Count; $i++) {
	$userName = $content1[$i]
	$computerName =  $content2[$i]

	# Define the local admin group
	$group = "Administrators"

	# Enable WinRM and configure necessary settings on the remote computer
	try
	{
		Invoke-Command -ComputerName $computerName -ScriptBlock {
			winrm quickconfig -force
			Start-Service WinRM
			Enable-PSRemoting -Force
			netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes
		}
		Write-Host "WinRM and necessary settings have been configured on $computerName."
	}
	catch
	{
		Write-Host "An error occurred while configuring WinRM: $_"
		exit
	}

	# Remove the user from the local admin group
	try
	{
		Invoke-Command -ComputerName $computerName -ScriptBlock {
			param ($userName, $group)
			Remove-LocalGroupMember -Group $group -Member $userName
		} -ArgumentList $userName, $group
		Write-Host "User $userName has been removed from the local admin group on $computerName."
	}
	catch
	{
		Write-Host "An error occurred: $_"
	}
}