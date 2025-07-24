# Import the Active Directory module
Import-Module ActiveDirectory

# Get all domain controllers in the domain
$domainControllers = Get-ADDomainController -Filter *

# Check for replication failures
foreach ($dc in $domainControllers) {
    Write-Host "Checking replication failures for Domain Controller: $($dc.Name)" -ForegroundColor Cyan
    $repFailures = Get-ADReplicationFailure -Target $dc.Name -ErrorAction SilentlyContinue

    if ($repFailures) {
        foreach ($failure in $repFailures) {
            # Display all properties of the failure object for debugging
            Write-Host "Details of the failure object:" -ForegroundColor Yellow
            $failure | Format-List *  # Show all available properties

            # Extract and display key details
            Write-Host "Failure Target: $($failure.FailureTarget)"
            Write-Host "Last Error Code: $($failure.LastErrorCode)"
            Write-Host "Last Error Message: $($failure.LastErrorMessage)"
            Write-Host "First Failure Time: $($failure.FirstFailureTime)"
            Write-Host "---------------"
        }
    } else {
        Write-Host "No replication failures detected for $($dc.Name)" -ForegroundColor Green
    }
}
