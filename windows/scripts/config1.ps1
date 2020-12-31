## basic config of template
# Configuration Windows Server installation
####
param($IP, $GW, $dns1, $dns2, $wsusserver, $wsusgroup)

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
    sleep -Milliseconds 600
}until ((get-service vmtools).status -eq "Running")

# set static ip
if ($IP) {
    write-host "Setting static ip $ip"
    New-NetIPAddress -InterfaceAlias Ethernet0 -IPAddress $IP -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway $GW | Out-Null
    get-netadapter -ifAlias Ethernet0 | Set-DnsClientServerAddress -ServerAddresses @($dns1, $dns2) | Out-Null
}
# Set Temp Variable using PowerShell

$TempFolder = "C:\TEMP"
write-host "Setting temp folder to $TempFolder"
New-Item -ItemType Directory -Force -Path $TempFolder | Out-Null
[Environment]::SetEnvironmentVariable("TEMP", $TempFolder, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("TMP", $TempFolder, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("TEMP", $TempFolder, [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("TMP", $TempFolder, [EnvironmentVariableTarget]::User)

# add root certificates
Import-Certificate -FilePath "a:\root1.p7b" -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
Import-Certificate -FilePath "a:\root2.p7b" -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
Import-Certificate -FilePath "a:\root3.p7b" -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
Import-Certificate -FilePath "a:\root3.p7b" -CertStoreLocation Cert:\LocalMachine\CA | Out-Null

# set wsus server
if ($wsusserver) {
    write-host "Setting wsus server to $wsusserver and group to $wsusgroup"
    new-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUServer" -value $wsusserver  | Out-Null
    new-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUStatusServer" -value $wsusserver  | Out-Null
    new-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetGroupEnabled" -PropertyType dword -value 1  | Out-Null
    new-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetGroup" -value $wsusgroup  | Out-Null
    new-item -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "AU"  | Out-Null
    new-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -PropertyType dword -value 1  | Out-Null
    restart-service wuauserv  | Out-Null
}

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