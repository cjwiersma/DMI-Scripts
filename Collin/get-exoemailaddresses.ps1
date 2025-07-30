# Exchange Online Email Address Extraction Script
# This script connects to Exchange Online and retrieves various types of email addresses

# Install required module if not already installed
# Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber

# Import the Exchange Online module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online (will prompt for credentials)
Write-Host "Connecting to Exchange Online..." -ForegroundColor Green
Connect-ExchangeOnline

try {
    # Option 1: Get all mailbox primary email addresses
    Write-Host "`nRetrieving all mailbox primary email addresses..." -ForegroundColor Yellow
    $mailboxes = Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName, PrimarySmtpAddress
    
    Write-Host "Primary Email Addresses:" -ForegroundColor Cyan
    $mailboxes | ForEach-Object {
        Write-Output "$($_.DisplayName): $($_.PrimarySmtpAddress)"
    }
    
    # Export primary addresses to CSV
    $mailboxes | Export-Csv -Path "PrimaryEmailAddresses.csv" -NoTypeInformation
    Write-Host "Primary email addresses exported to PrimaryEmailAddresses.csv" -ForegroundColor Green
    
    # Option 2: Get ALL email addresses (including aliases) for each mailbox
    Write-Host "`nRetrieving ALL email addresses (including aliases)..." -ForegroundColor Yellow
    $allAddresses = @()
    
    Get-Mailbox -ResultSize Unlimited | ForEach-Object {
        $mailbox = $_
        $_.EmailAddresses | Where-Object {$_.PrefixString -eq "smtp" -or $_.PrefixString -eq "SMTP"} | ForEach-Object {
            $allAddresses += [PSCustomObject]@{
                DisplayName = $mailbox.DisplayName
                EmailAddress = $_.SmtpAddress
                IsPrimary = ($_.PrefixString -eq "SMTP")
            }
        }
    }
    
    Write-Host "All Email Addresses (including aliases):" -ForegroundColor Cyan
    $allAddresses | Format-Table -AutoSize
    
    # Export all addresses to CSV
    $allAddresses | Export-Csv -Path "AllEmailAddresses.csv" -NoTypeInformation
    Write-Host "All email addresses exported to AllEmailAddresses.csv" -ForegroundColor Green
    
    # Option 3: Get distribution group email addresses
    Write-Host "`nRetrieving distribution group email addresses..." -ForegroundColor Yellow
    $distributionGroups = Get-DistributionGroup -ResultSize Unlimited | Select-Object DisplayName, PrimarySmtpAddress
    
    Write-Host "Distribution Group Email Addresses:" -ForegroundColor Cyan
    $distributionGroups | ForEach-Object {
        Write-Output "$($_.DisplayName): $($_.PrimarySmtpAddress)"
    }
    
    # Export distribution group addresses to CSV
    $distributionGroups | Export-Csv -Path "DistributionGroupAddresses.csv" -NoTypeInformation
    Write-Host "Distribution group addresses exported to DistributionGroupAddresses.csv" -ForegroundColor Green
    
    # Option 4: Get shared mailbox email addresses
    Write-Host "`nRetrieving shared mailbox email addresses..." -ForegroundColor Yellow
    $sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | Select-Object DisplayName, PrimarySmtpAddress
    
    Write-Host "Shared Mailbox Email Addresses:" -ForegroundColor Cyan
    $sharedMailboxes | ForEach-Object {
        Write-Output "$($_.DisplayName): $($_.PrimarySmtpAddress)"
    }
    
    # Export shared mailbox addresses to CSV
    $sharedMailboxes | Export-Csv -Path "SharedMailboxAddresses.csv" -NoTypeInformation
    Write-Host "Shared mailbox addresses exported to SharedMailboxAddresses.csv" -ForegroundColor Green
    
    # Summary
    Write-Host "`n--- SUMMARY ---" -ForegroundColor Magenta
    Write-Host "Total Mailboxes: $($mailboxes.Count)" -ForegroundColor White
    Write-Host "Total Email Addresses (including aliases): $($allAddresses.Count)" -ForegroundColor White
    Write-Host "Total Distribution Groups: $($distributionGroups.Count)" -ForegroundColor White
    Write-Host "Total Shared Mailboxes: $($sharedMailboxes.Count)" -ForegroundColor White
    
    # Create a master list of all unique email addresses
    $masterList = @()
    $masterList += $allAddresses.EmailAddress
    $masterList += $distributionGroups.PrimarySmtpAddress
    $masterList += $sharedMailboxes.PrimarySmtpAddress
    
    $uniqueAddresses = $masterList | Sort-Object -Unique
    $uniqueAddresses | Out-File -FilePath "MasterEmailList.txt"
    Write-Host "Master list of all unique email addresses saved to MasterEmailList.txt ($($uniqueAddresses.Count) total)" -ForegroundColor Green
    
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
} finally {
    # Disconnect from Exchange Online
    Write-Host "`nDisconnecting from Exchange Online..." -ForegroundColor Green
    Disconnect-ExchangeOnline -Confirm:$false
}

Write-Host "`nScript completed successfully!" -ForegroundColor Green