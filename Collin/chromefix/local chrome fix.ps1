
Invoke-Command -ScriptBlock {
	$KEYS1 = @()
	$KEYS2 = @()

	$KEYS1Path = "HKLM:\SOFTWARE\Classes\Installer\Products\"
	$KEYS2Path = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\"

	$KEYS1 = (Get-ItemProperty "HKLM:\SOFTWARE\Classes\Installer\Products\*" -ErrorAction SilentlyContinue | Where-Object {$_ -like "*Chrome*"}).PSChildName
	$KEYS1

	$KEYS2 = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\*" -ErrorAction SilentlyContinue | Where-Object {$_ -like "*Chrome*"}).PSChildName
	$KEYS2

	Foreach($Key1 in $KEYS1)
		{
			Rename-Item -Path $KEYS1Path$Key1 -NewName "$Key1.OLD"
		}

	Foreach($Key2 in $KEYS2)
		{
			Rename-Item -Path $KEYS2Path$Key2 -NewName "$Key2.OLD"
		}
	}
Invoke-Command -ScriptBlock {
	$msiPath = "\\dmicorp.com\install\Chrome\googlechromestandaloneenterprise64.msi"
	Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $msiPath /quiet" -Wait
	}