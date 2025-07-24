$ErrorActionPreference = "Stop"

try {
    $checkHealth = Read-Host "Do you want to check the health of the machine? (yes/no)"
    if ($checkHealth -eq "yes") {
        $scriptBlock = {
            DISM /Online /Cleanup-Image /CheckHealth
            $continue = Read-Host "Do you want to scan for corrupted files? (yes/no)"
            if ($continue -eq "yes") {
                DISM /Online /Cleanup-Image /ScanHealth
                $restore = Read-Host "Do you want to restore the image? (yes/no)"
                if ($restore -eq "yes") {
                    DISM /Online /Cleanup-Image /RestoreHealth
                }
            }
        }

        $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($scriptBlock.ToString()))
        Start-Process powershell -Verb RunAs -ArgumentList "-NoExit -EncodedCommand $encoded"
    } else {
        exit
    }
}
catch {
    Write-Error $_.Exception.Message
    pause
    exit 1
}

