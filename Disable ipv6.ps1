#Gets the network adapter binding information first. Can take off the Interface alias to see all. 

Get-NetAdapterBinding –InterfaceAlias “Ethernet0”

#Then disable the IPv6

Disable-NetAdapterBinding –InterfaceAlias “Ethernet0” –ComponentID ms_tcpip6