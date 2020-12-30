param($IP, $GW, $dns1, $dns2)
New-NetIPAddress -InterfaceAlias Ethernet0 -IPAddress $IP -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway $GW
get-netadapter -ifAlias Ethernet0 | Set-DnsClientServerAddress -ServerAddresses @($dns1, $dns2)