# Import the Active Directory module
Import-Module ActiveDirectory

# Get the current domain's replication metadata
$domainControllers = Get-ADDomainController -Filter *

foreach ($dc in $domainControllers) {
    Write-Host "Checking replication for Domain Controller: $($dc.Name)" -ForegroundColor Cyan
    $replicationData = Get-ADReplicationPartnerMetadata -Target $dc.Name -Partition "DC=SCNET,DC=local" -ErrorAction SilentlyContinue

    if ($replicationData) {
        foreach ($partner in $replicationData) {
            Write-Host "Partner: $($partner.PartnerName)"
            Write-Host "Last Attempt: $($partner.LastReplicationAttempt)"
            Write-Host "Last Success: $($partner.LastReplicationSuccess)"
            Write-Host "Consecutive Failures: $($partner.NumberOfConsecutiveReplicationFailures)"
            Write-Host "---------------"
        }
    } else {
        Write-Host "No replication data available for $($dc.Name)" -ForegroundColor Yellow
    }
}
