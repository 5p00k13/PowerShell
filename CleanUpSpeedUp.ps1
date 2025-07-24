
# Check if running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    # Relaunch script with Admin privileges in a new window
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = "-NoExit -File `"$PSCommandPath`"";
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
    exit;
}

# This is where the main script continues
Write-Host "Running with admin privileges."



# Function to change power plan to High Performance or Ultimate Performance (if available)
function Set-HighPerformancePowerPlan {
    Write-Host "Setting power plan to High Performance..." -ForegroundColor Yellow

    $powerPlans = powercfg /l

    if ($powerPlans -like "*Ultimate Performance*") {
        Write-Host "Ultimate Performance plan found. Setting it as the active plan." -ForegroundColor Green
        powercfg /s E9A42B02-D5DF-448D-AA00-03F14749EB61
    } else {
        Write-Host "Ultimate Performance plan not found. Setting High Performance plan instead." -ForegroundColor Green
        powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    }
}

# Function to delete temporary files with error handling for access-denied issues
function Clear-TempFiles {
    Write-Host "Clearing temporary files..." -ForegroundColor Yellow
    $tempPaths = @($env:TEMP, $env:TMP, "$env:Windir\Temp")
    foreach ($tempPath in $tempPaths) {
        if (Test-Path $tempPath) {
            Get-ChildItem $tempPath -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    Remove-Item -Force -Recurse -ErrorAction Stop
                }
                catch {
                    Write-Host "Access denied to $($_.FullName), skipping..." -ForegroundColor Red
                }
            }
        }
    }
}

# Function to clear DNS cache
function Clear-DNSCache {
    Write-Host "Clearing DNS cache..." -ForegroundColor Yellow
    ipconfig /flushdns
}

# Function to clear Windows Update cache with elevated permissions check
function Clear-WindowsUpdateCache {
    Write-Host "Clearing Windows Update cache..." -ForegroundColor Yellow
    try {
        Stop-Service -Name wuauserv -Force -ErrorAction Stop
        Remove-Item -Recurse -Force "C:\Windows\SoftwareDistribution\Download" -ErrorAction Stop
        Start-Service -Name wuauserv
    }
    catch {
        Write-Host "Could not clear Windows Update cache: $_" -ForegroundColor Red
    }
}

# Function to restart necessary services
function Restart-Services {
    Write-Host "Restarting services..." -ForegroundColor Yellow
    $services = @("wuauserv", "bits", "Dnscache")
    foreach ($service in $services) {
        try {
            Restart-Service $service -Force -ErrorAction Stop
        }
        catch {
            Write-Host "Could not restart service: $service" -ForegroundColor Red
        }
    }
}

# Function to clear browser cache (only Internet Explorer/Edge)
function Clear-BrowserCache {
    Write-Host "Clearing browser cache..." -ForegroundColor Yellow
    RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
}

# Function to run Disk Cleanup (cleanmgr)
function Run-DiskCleanup {
    Write-Host "Running Disk Cleanup..." -ForegroundColor Yellow
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -NoNewWindow -Wait
}


Write-Host "Starting system optimization..." -ForegroundColor Green

Clear-TempFiles
Clear-DNSCache
Clear-WindowsUpdateCache
Clear-BrowserCache
Restart-Services
Run-DiskCleanup
Set-HighPerformancePowerPlan

Write-Host "System optimization complete!" -ForegroundColor Green
