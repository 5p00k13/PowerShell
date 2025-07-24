# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt for domain admin credentials
$cred = Get-Credential -Message "Enter Domain Admin credentials"

# Prompt for user details
$firstName = Read-Host "Enter First Name"
$lastName = Read-Host "Enter Last Name"
$userName = Read-Host "Enter Username"

# Define the default password
$password = ConvertTo-SecureString "Streamline@123" -AsPlainText -Force

# Construct the full name and other details
$fullName = "$firstName $lastName"
$ouPath = "OU=Streamline,OU=Users,OU=!SmartcareNet,DC=smartcarenet,DC=com  "  # Correct OU path
$userPrincipalName = "$userName@SmartcareNet.com"  # Ensure this domain is correct

# Create the user account in a disabled state and set the account to never expire
try {
    New-ADUser `
        -Name $fullName `
        -GivenName $firstName `
        -Surname $lastName `
        -SamAccountName $userName `
        -UserPrincipalName $userPrincipalName `
        -Path $ouPath `
        -AccountPassword $password `
        -Enabled $false `  # Create the account in a disabled state
        -PasswordNeverExpires $true `  # Set the account to never expire
        -PassThru # Display the created user object in the console
}

catch {
    Write-Host "Error during user creation: $_"
}
