function Update-UnattendXml {
    param (
        [string]$Path,
        [string]$Password,
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
        $UnattendXml.Save($ResolvedPath)
    }
    catch {
        $_.Exception.Message
    }
}
function deploy-template {
    param(
        [Parameter(mandatory = $true)]$Template_file,
        [Parameter(mandatory = $true)]$Template_var_file,
        [Parameter(mandatory = $true)]$template_edition,
        [Parameter(mandatory = $true)]$template_unattended,
        [Parameter(mandatory = $true)]$template_path_packer,
        [pscredential]$credential,
        [string]$winadmin_password
    )
  
    if ($env:path -notlike "*$template_path_packer*") { $env:path += ";$template_path_packer" }
    if (!$credential) { $credential = get-credential }
    if (!$winadmin_password) { $winadmin_password = Read-Host 'Enter local admin password' }
    Update-UnattendXml -path $template_unattended -password $winadmin_password -edition $template_edition
    packer build -force --var-file $Template_var_file -var "vcenter_username=$($Credentials.username)"  -var "vcenter_password=$($Credentials.GetNetworkCredential().Password)"  -var "winadmin-password=$winadmin_password" $Template_file
    Update-UnattendXml -path $template_unattended -password "password" -edition $template_edition
}