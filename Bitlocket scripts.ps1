# Open PowerShell as Administrator and run the following commands

# Check BitLocker status
Get-BitLockerVolume

# Backup the BitLocker recovery key to Active Directory or a file
Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId (Get-BitLockerVolume -MountPoint "C:").KeyProtector[0].KeyProtectorId

# Suspend BitLocker
Suspend-BitLocker -MountPoint "C:" -RebootCount 1

# Resume BitLocker
Resume-BitLocker -MountPoint "C:"

# Decrypt the drive
Disable-BitLocker -MountPoint "C:"

# Wait for the decryption process to complete, then re-enable BitLocker
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly

