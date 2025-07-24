# Get your public IP address
$publicIP = Invoke-RestMethod -Uri "https://api.ipify.org?format=json" | Select-Object -ExpandProperty ip

# Query information about the IP address
$ispInfo = Invoke-RestMethod -Uri "http://ip-api.com/json/$publicIP"

# Display the ISP information
"Your ISP is: $($ispInfo.isp)"
