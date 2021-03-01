function Update-UnattendXml {
    # update autounattended.xml for windows installation with custom vars
    param (
        [string]$autounattend,
        [string]$Password,
        $packervars,
        [switch]$reset
    )
    $editions = @{
        core     = "Windows Server 2019 SERVERSTANDARDCORE"
        standard = "Windows Server 2019 SERVERSTANDARD"
    }
    $ErrorActionPreference = 'Stop'
    try {
        $ResolvedPath = (Resolve-Path -Path $autounattend).Path
        [xml]$UnattendXml = Get-Content -Path $ResolvedPath
        $AdminPW = $UnattendXml.unattend.settings.component.useraccounts.administratorpassword
        $ALAdminPW = $UnattendXml.unattend.settings.component.autologon.password
        # decode [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Test))
        if ($AdminPW.PlainText -eq 'false') {
            $PlainText = '{0}AdministratorPassword' -f $Password
            $AdminPW.Value = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($PlainText))
            $ALAdminPW.Value = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($PlainText))
        }
        else {
            $AdminPW.Value = $Password
            $ALAdminPW.Value = $Password
        }
        foreach ($item in $UnattendXml.unattend.settings.component.firstlogoncommands.SynchronousCommand | where-object { $_.commandline -like "*01_init.ps1*" }) {
            $item.commandline = 'cmd.exe /c C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File a:\01_init.ps1 -psvarfile "a:\'+$packervars.os_psvarfile+'"'
        }
        $UnattendXml.unattend.settings.component.imageinstall.osimage.installfrom.metadata.value = $editions.($packervars.os_edition)
        if ($packervars.os_productkey){$UnattendXml.unattend.settings.component[1].userdata.productkey.key = $packervars.os_productkey}
        if ($packervars.os_fullname){$UnattendXml.unattend.settings.component[1].userdata.fullname = $packervars.os_fullname}
        if ($packervars.os_organization){$UnattendXml.unattend.settings.component[1].userdata.organization = $packervars.os_organization}
        if ($packervars.vm_name){$UnattendXml.unattend.settings.component[2].computername = $packervars.vm_name}
        
        $UnattendXml.Save($ResolvedPath)
    }
    catch {
        $_.Exception.Message
    }
}

function publish-template {
    param(
        [Parameter(mandatory = $true)]$Template_file,
        [Parameter(mandatory = $true)]$Template_var_file,
        [Parameter(mandatory = $true)]$Builder_var_file,
        [Parameter(mandatory = $true)]$path_packer,
        [Parameter(mandatory = $false)]$template_path,
        [string]$autounattend_file,
        [pscredential]$credential,
        [string]$local_admin_pass
    )
    $packervars = Get-Content -Path $Template_var_file | ConvertFrom-Json
    if ($env:path -notlike "*$path_packer*") { $env:path += ";$path_packer" }
    if (!$credential) { $credential = get-credential }
    if ($packervars.os_type -eq "windows") { 
        $autounattend="$template_path\autounattend.xml"
        #copy var file 
        Copy-Item -Path $Template_var_file -Destination ($template_path+"/"+$packervars.os_psvarfile)
        # copy autounattend.xml
        copy-item -path $autounattend_file -Destination $autounattend
        # enter local asmin password for os
        if (!$local_admin_pass) { $local_admin_pass = Read-Host "Enter local administrator password" }
        # update autounattend file
        Update-UnattendXml -autounattend $autounattend -password $local_admin_pass -packervars $packervars
        # start packer build
        packer build -force --var-file $builder_var_file --var-file $Template_var_file -var "vcenter_username=$($Credential.username)"  -var "vcenter_password=$($Credential.GetNetworkCredential().Password)"  -var "os_admin_password=$local_admin_pass" $Template_file
        # clean up
        remove-item -path ($template_path+"/"+$packervars.os_psvarfile) 
        remove-item -path $autounattend
    }
    if ($packervars.os_type -eq "linux") {
        packer build -force --var-file $builder_var_file --var-file $Template_var_file -var "vcenter_username=$($Credential.username)"  -var "vcenter_password=$($Credential.GetNetworkCredential().Password)" $Template_file   
    }
}
