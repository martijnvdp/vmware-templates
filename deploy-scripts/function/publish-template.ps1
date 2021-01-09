function Update-UnattendXml {
    param (
        [string]$Path,
        [string]$Password,
        $static_ip,
        $default_gw,
        $wsus_server,
        $wsus_group,
        $dns1 = "8.8.8.8",
        $dns2 = "8.8.4.4",
        [Parameter(mandatory = $true)][validateset("core", "standard")][string]$Edition
    )
    $editions = @{
        core     = "Windows Server 2019 SERVERSTANDARDCORE"
        standard = "Windows Server 2019 SERVERSTANDARD"
    }
    $ErrorActionPreference = 'Stop'
    try {
        $ResolvedPath = (Resolve-Path -Path $Path).Path
        [xml]$UnattendXml = Get-Content -Path $ResolvedPath
        $AdminPW = $UnattendXml.unattend.settings.component.useraccounts.administratorpassword
        $ALAdminPW = $UnattendXml.unattend.settings.component.autologon.password
        $UnattendXml.unattend.settings.component.imageinstall.osimage.installfrom.metadata.value = $editions.$edition
        if ($AdminPW.PlainText -eq 'false') {
            $PlainText = '{0}AdministratorPassword' -f $Password
            $AdminPW.Value = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($PlainText))
            $ALAdminPW.Value = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($PlainText))
        }
        else {
            $AdminPW.Value = $Password
            $ALAdminPW.Value = $Password
        }
        #static ip
        if ($static_ip) { $params = $params + " -IP `"$static_ip`" -GW `"$default_gw`" -DNS1 `"$dns1`" -DNS2 `"$dns2`"" }
        #wsus server
        if ($wsus_server) { $params = $params + " -wsusserver `"$wsus_server`" -wsusgroup `"$wsus_group`"" }
        #set script params
        foreach ($item in $UnattendXml.unattend.settings.component.firstlogoncommands.SynchronousCommand | where-object { $_.commandline -like "*config1.ps1*" }) {
            $item.commandline = "cmd.exe /c C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File a:\config1.ps1 $params"
        }
        $UnattendXml.Save($ResolvedPath)
    }
    catch {
        $_.Exception.Message
    }
}
function publish-template {
    param(
        [Parameter(mandatory = $true)]$Template_os,
        [Parameter(mandatory = $true)]$Template_file,
        [Parameter(mandatory = $true)]$Template_var_file,
        [Parameter(mandatory = $true)]$Builder_var_file,
        $template_edition,
        $template_unattended,
        [Parameter(mandatory = $true)]$template_path_packer,
        $static_ip,
        $default_gw,
        $dns1,
        $dns2,
        $wsus_server,
        $wsus_group,
        [pscredential]$credential,
        [string]$winadmin_password
    )
    if ($env:path -notlike "*$template_path_packer*") { $env:path += ";$template_path_packer" }
    if (!$credential) { $credential = get-credential }
    if ($Template_os -eq "windows") { 
        $winadmin_password = Read-Host "Enter local administrator password" 
        Update-UnattendXml -path $template_unattended -password $winadmin_password -edition $template_edition -static_ip $static_ip -default_gw $default_gw -wsus_server $wsus_server -wsus_group $wsus_group
        packer build -force --var-file $builder_var_file --var-file $Template_var_file -var "vcenter_username=$($Credential.username)"  -var "vcenter_password=$($Credential.GetNetworkCredential().Password)"  -var "winadmin-password=$winadmin_password" $Template_file
        Update-UnattendXml -path $template_unattended -password "password" -edition $template_edition -static_ip "0.0.0.0" -default_gw "0.0.0.0"
    }
    if ($Template_os -eq "ubuntu") {
        packer build -force --var-file $builder_var_file --var-file $Template_var_file -var "vcenter_username=$($Credential.username)"  -var "vcenter_password=$($Credential.GetNetworkCredential().Password)" $Template_file   
    }
}