Invoke-Command -ComputerName pc8560 -ScriptBlock {
    Start-Process -FilePath "\\dmi2\systems\Helpdesk\CMS Upgrade\SetupSup_QA20.exe" -ArgumentList "/silent", "/install" -Wait
    Start-Process -FilePath "\\dmi2\systems\Helpdesk\CMS Upgrade\SetupTE_QA20.exe" -ArgumentList "/silent", "/install" -Wait
}