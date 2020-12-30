# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer
#####vars
$Template_file = ".\win2019.standard.json"
$Template_var_file = ".\win2019.variables.json"
$template_edition = "standard"
$template_unattended = ".\autounattend.xml"
$template_path_packer = "c:\packer"
##end vars

function Update-UnattendXml {
    param (
        [string]$Path,
        [string]$Password,
        [Parameter(mandatory = $true)][validateset("core", "standard")][string]$Edition
    )
    $editions = @{
        core     = "Windows Server 2019 SERVERCORE"
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
if ($env:path -notlike "*$template_path_packer*") { $env:path += ";$template_path_packer" }
$credentials = get-credential
$winadmin_password = Read-Host 'Enter local admin password'
Update-UnattendXml -path $template_unattended -password $winadmin_password -edition $template_edition
packer build -force --var-file $Template_var_file -var "vcenter_username=$($Credentials.username)"  -var "vcenter_password=$($Credentials.GetNetworkCredential().Password)"  -var "winadmin-password=$winadmin_password" $Template_file
Update-UnattendXml -path $template_unattended -password "password" -edition $template_edition