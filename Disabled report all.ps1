# Load the Active Directory module (if not already loaded)
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Import-Module ActiveDirectory
}

# Specify the time frame for the report (start and end dates)
$startDate = Get-Date "2024-10-31"
$endDate = Get-Date "2025-03-11"

# Search for disabled accounts and filter by whenChanged property within Get-ADUser
$disabledAccounts = Get-ADUser -Filter {
    Enabled -eq $false -and whenChanged -ge $startDate -and whenChanged -le $endDate
} -Properties whenChanged

# Create a report
$reportPath = "C:\Users\clewis\Desktop\Reports\DisabledAccountsReport.csv"
$disabledAccounts | Select-Object Name, SamAccountName, whenChanged | Export-Csv -Path $reportPath -NoTypeInformation

# Output where the report is saved
Write-Host "Report generated at $reportPath"
