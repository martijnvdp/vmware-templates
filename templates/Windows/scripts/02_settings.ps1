# general settings

$psvars = Get-Content -Path a:\$env:psvarfile | ConvertFrom-Json
#$ErrorActionPreference = "Stop"

Start-Transcript -Path ($psvars.os_deployment_log_file) -Append

# Set Temp Variable using PowerShell
$TempFolder = "C:\TEMP"
write-host "Setting temp folder to $TempFolder"
if (!(test-path $TempFolder)) {New-Item -ItemType Directory -Force -Path $TempFolder | Out-Null } 
[Environment]::SetEnvironmentVariable("TEMP", $TempFolder, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("TMP", $TempFolder, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("TEMP", $TempFolder, [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("TMP", $TempFolder, [EnvironmentVariableTarget]::User)

# set wsus server
if ($psvars.os_wsus_server) {
    write-host "Setting wsus server to "($psvars.os_wsus_server)" and group to "($psvars.os_wsus_group)
    new-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUServer" -value ($psvars.os_wsus_server)  | Out-Null
    new-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUStatusServer" -value ($psvars.os_wsus_server)  | Out-Null
    new-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetGroupEnabled" -PropertyType dword -value 1  | Out-Null
    new-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetGroup" -value ($psvars.os_wsus_group)  | Out-Null
    if (!(test-path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate")){ new-item -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "AU"  | Out-Null }
    new-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -PropertyType dword -value 1  | Out-Null
    restart-service wuauserv  | Out-Null
}

#disable ipv6 and other components
Get-NetAdapter | Disable-NetAdapterBinding -ComponentID ms_tcpip6 -Confirm:$false
Get-NetAdapter | Disable-NetAdapterBinding -ComponentID ms_implat -Confirm:$false

# SettingSet Explorer view options
Write-Host "Setting default Explorer view options"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideDrivesWithNoMedia" 0 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0 | Out-Null

# Disable system hibernation
Write-Host "Disabling system hibernation"
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HiberFileSizePercent" -Value 0 | Out-Null
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HibernateEnabled" -Value 0 | Out-Null

# Disable password expiration for Administrator
Write-Host "Disabling password expiration for local Administrator user"
Set-LocalUser Administrator -PasswordNeverExpires $true

# Enabling RDP connections
Write-Host "Enabling RDP connections"
netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 | Out-Null

#time zone
Set-TimeZone -Name "W. Europe Standard Time"

# Variables
#$certUrl = "http://<<PKI server>>/CertEnroll"
#$certRoot = "Root-CA.crt"
#$certIssuing = "uIssuing-CA.crt"
#$repository = "http://<<artifactory>>:8082/artifactory/packer-local/windows/common/utils/BGinfo"
#$bgiBinary = "Bginfo64.exe"
#$bgiConfig = "v12n.bgi"

#ssh
# Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
# Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install trusted CA certificates

# Get certificates
#ForEach ($cert in $certRoot,$certIssuing) {
#  Invoke-WebRequest -Uri ($certUrl + "/" + $cert) -OutFile C:\$cert
#}

# Import Root CA certificate
#Import-Certificate -FilePath C:\$certRoot -CertStoreLocation 'Cert:\LocalMachine\Root'

# Import Issuing CA certificate
#Import-Certificate -FilePath C:\$certIssuing -CertStoreLocation 'Cert:\LocalMachine\CA'

# Delete certificates
#ForEach ($cert in $certRoot,$certIssuing) {
#  Remove-Item C:\$cert -Confirm:$false
#}
Stop-Transcript