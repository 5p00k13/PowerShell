Add-Computer -ComputerName $env:COMPUTERNAME -OUPath "OU=Domain Workstations,OU=!SmartcareNet,DC=smartcarenet,DC=com" -DomainName smartcarenet.com -Credential (Get-Credential) -Server portagedc12.smartcarenet.com

