$computers = Get-ADComputer -Filter {Enabled -eq $false}

foreach ($computer in $computers) {
    Write-Output $computer.Name
}
