# Init config and vmware tools installation for winrm 

param($psvarfile)
$psvars = Get-Content -Path $psvarfile | ConvertFrom-Json

Start-Transcript -Path ($psvars.os_deployment_log_file) -Append

#set u drive online
#set-disk -Number 1 -IsOffline:$false
#set-disk -Number 1 -IsReadonly:$false

# disble winrm
Write-Host "Disable winrm"
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=block
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes
$winrmService = Get-Service -Name WinRM
if ($winrmService.Status -eq "Running") {
    Disable-PSRemoting -Force
}
Stop-Service winrm
Set-Service -Name winrm -StartupType Disabled

# Disable network discovery
Write-Host "Disable network discovery"
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force | Out-Null
netsh advfirewall firewall set rule group="Network Discovery" new enable=No

# install vmware tools Silent mode, basic UI, no reboot
write-host "install vmware tools"
& e:\setup64 /s /v "/qb REBOOT=R" 

# wait for tools
do {
    Write-Host "Waiting for vmware tools..."
sleep 2
}until ((get-service vmtools -erroraction 'silentlycontinue' ).status -eq "Running")

# set static ip
if ($psvars.os_static_ip) {
    write-host "Setting static ip "($psvars.os_static_ip)
    New-NetIPAddress -InterfaceAlias Ethernet0 -IPAddress ($psvars.os_static_ip) -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway ($psvars.os_default_GW) | Out-Null
    get-netadapter -ifAlias Ethernet0 | Set-DnsClientServerAddress -ServerAddresses @(($psvars.os_dns1), ($psvars.os_dns2)) | Out-Null
}
# sleep to prevent error on enabling winrm
sleep 20

# enable winrm
write-host "Enabling winrm"
$NetworkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$Connections = $NetworkListManager.GetNetworkConnections()
$Connections | ForEach-Object { $_.GetNetwork().SetCategory(1) } 

Enable-PSRemoting -Force
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow
Set-Service winrm -startuptype "auto"
Restart-Service winrm | Out-Null

Stop-Transcript