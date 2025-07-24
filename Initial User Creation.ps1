#Initial User Creation
Set-Alias -Name gam -Value "C:\GAMADV-XTD3\gam.exe"
if (!$domainadmincreds) { $domainadmincreds = Get-Credential -Message "DomainAdmincreds" }
$ImportCSV=import-csv "C:\Users\clewis\Documents\Save\NewUserCreation.csv" | Where-Object ignore -ne 'x'
foreach ($csv in ($ImportCSV | where-object { $_.ignore -notmatch '\w' })) {
    
    #if first name has non-letter characters, remove them for the email but leave them so they can be used in the displayname. 
    if ($csv.First -match '\W' -or $csv.Last -match '\W') {
        $emailfirst = $csv.First -replace '\W', ''
        $emailLast = $csv.Last -replace '\W', ''
        $csv.Email = "$($emailfirst).$($emailLast)@streamlinehealthcare.com"
    }
    If ($csv.Skipgsuite -notmatch '\w') {

        #get groups to add user to after creation, this is based on the "CopyFrom" column on the csv and this value must match an account.
        #You should run "gam print info <CopyFromUser>" against each entry in the copyfrom column or it may have unintended consequences.
        $groupstocopy = gam print groups member "$($CSV.CopyFrom)@streamlinehealthcare.com" | convertfrom-csv
        $groupstocopy += gam print groups member "$($CSV.CopyFrom)@smartcarenet.com.com" | convertfrom-csv
        

        #Create user
        gam create user $csv.email firstname $csv.first lastname $csv.last password "$($csv.TempPassword)" gal on

        #if manager defined in csv set manager, otherwise set all other params and worry about it later
        if ($csv.Manager) { gam update user $csv.Email relation manager "$($csv.Manager)@streamlinehealthcare.com" organization name `"Streamline Healthcare Solutions`" type `"Work`" title $csv.Title }
        else { gam update user $csv.Email organization name `"Streamline Healthcare Solutions`" type `"Work`" title $csv.Title }
        #Add user to each group
        foreach ($group in $groupstocopy) { gam update group $group.email add member $csv.email }
    }
    if ($CSV.SkipActiveDirectory -notmatch '\w') {
        #ADUserCreation
        $ADGroupsToAdd = @((get-aduser -filter "emailaddress -eq '$($csv.CopyFrom)@smartcarenet.com'" -Properties memberof -ErrorVariable AdGroupstoAddError -Server portagedc12.smartcarenet.com),(get-aduser -filter "emailaddress -eq '$($csv.CopyFrom)@streamlinehealthcare.com'" -Properties memberof -ErrorVariable AdGroupstoAddError -Server portagedc12.smartcarenet.com))
        if (!$AdGroupstoAdd -and $force) { "" }
        while (!$AdGroupstoAdd -and !$force) {
            $csv.CopyFrom = Read-Host -Prompt "Looks like $($CSV.CopyFrom)@smartcarenet.com isnt a valid UserPrincipalName type a new UPN to copy groups from"
            $ADGroupsToAdd = get-aduser -filter "emailaddress -eq '$($csv.CopyFrom)@smartcarenet.com'" -Properties memberof -ErrorVariable AdGroupstoAddError -Server portagedc12.smartcarenet.com
        }
        
    
        
        $Splat = @{
            #Trim SAMAccountName to max of 20 characters. 
            SAMAccountName    = ($csv.First[0] + $csv.Last -replace '\W', '').Substring(0, [system.math]::Min(19, (($csv.First[0] + $csv.Last -replace '\W', '').length)))
            GivenName         = $CSV.First
            Surname           = $csv.Last
            EmailAddress      = $csv.Email
            UserPrincipalName = ($csv.First[0] + $csv.Last -replace '\W', '').Substring(0, [system.math]::Min(19, (($csv.First[0] + $csv.Last -replace '\W', '').length))) + '@smartcarenet.com'
            Path              = 'OU=Streamline,OU=Users,OU=!SmartcareNet,DC=smartcarenet,DC=com'
            Name              = $csv.First + ' ' + $csv.last
            AccountPassword   = $csv.TempPassword | ConvertTo-SecureString -Force -AsPlainText
            displayname       = "$($csv.last), $($csv.first)"
            server= "portagedc12.smartcarenet.com"
        }

        New-ADUser @Splat -Verbose -Credential $domainadmincreds
        while (![bool](Get-ADUser $Splat.SAMAccountName -server portagedc12.smartcarenet.com)){
            "Couldn't Find account $($Splat.SAMAccountName) Trying again in 10 seconds"
            Start-Sleep -seconds 10
        }
        Set-ADAccountPassword -Identity $Splat.SAMAccountName -NewPassword $Splat.AccountPassword -Server Portagedc12.smartcarenet.com
        $ADGroupsToAdd.MemberOf | ForEach-Object { Add-ADGroupMember -Identity $_ -Members $Splat.SAMAccountName -Verbose -Credential $domainadmincreds -Server portagedc12.smartcarenet.com }
        Get-ADUser $Splat.SAMAccountName -Server portagedc12.smartcarenet.com| Enable-ADAccount -Server portagedc12.smartcarenet.com
    }
    if ($csv.SkipMSOL -notmatch '\w') {
        New-AzADUser -DisplayName "$($csv.First) $($csv.Last)" -UserPrincipalName "$($csv.Email)" -MailNickname "$($csv.First).$($csv.Last)" -AccountEnabled $true -Password ($csv.TempPassword | ConvertTo-SecureString -Force -AsPlainText)
        #Update-AzADUser -UserPrincipalName $csv.Email -EnableAccount "True"
    }
    Read-Host "Finished $($CSV.First+' '+ $CSV.Last)"


}