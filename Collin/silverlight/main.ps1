$computerName = pc7514
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

	}

	# Remove the user from the local admin group
	try
	{
		$scriptBlock = {
			reg delete HKLM\Software\Microsoft\Silverlight /f
			reg delete HKEY_CLASSES_ROOT\Installer\Products\D7314F9862C648A4DB8BE2A5B47BE100 /f
			reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\D7314F9862C648A4DB8BE2A5B47BE100 /f
			reg delete HKEY_CLASSES_ROOT\TypeLib\{283C8576-0726-4DBC-9609-3F855162009A} /f
			reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\install.exe /f
			reg delete HKEY_CLASSES_ROOT\AgControl.AgControl /f
			reg delete HKEY_CLASSES_ROOT\AgControl.AgControl.5.1 /f
			reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{89F4137D-6C26-4A84-BDB8-2E5A4BB71E00} /f
			rmdir /s /q "$env:ProgramFiles\Microsoft Silverlight"
			rmdir /s /q "$env:ProgramFiles(x86)\Microsoft Silverlight"
		}
		Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock -Credential (Get-Credential)
	}
	catch
	{
		Write-Host "An error occurred: $_"
	}
