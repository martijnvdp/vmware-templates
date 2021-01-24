Param([pscredential]$credential, $local_admin_pass)
# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer

. "$PSScriptRoot/function/publish-template.ps1"
#####
$deploy_params = @{
    template_file        = $PSscriptroot + "/../templates/Windows/2019/Standard.json"
    template_var_file    = $PSscriptroot + "/../templates/Windows/2019/Standard.variables.json"
    builder_var_file     = $PSscriptroot + "/../../vars/vsphere-iso.variables.json"
    template_unattended  = $PSscriptroot + "/../templates/windows/2019/autounattend.xml"
    iso_url              = "file://$home/Downloads/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
    iso_checksum         = "549BCA46C055157291BE6C22A3AAAED8330E78EF4382C99EE82C896426A1CEE1"
    template_edition     = "standard"
    Template_os          = "windows"
    template_path_packer = "c:\packer" 
    #optional static ip
    # static_ip "1.2.3.4"
    # default_gw "1.2.3.1"
    # dns1 "8.8.8.8"
    # dns2 "8.8.4.4"
    # wsus_server "wsus.server.internal"
    # wsus_group "wsus_target_group"
}
#####
#if ($Islinux -and !(test-path "/$($iso_url.trim("file://"))")) {python3 $PSscriptroot/deploy-scripts/function/autodownload-windows2019eval.py}
if (!(test-path $deploy_params.builder_var_file)) { $deploy_params.builder_var_file = $PSscriptroot + "/../builders/vsphere-iso/vsphere-iso.variables.json" } 
publish-template @deploy_params -Credential $credential -local_admin_pass $local_admin_pass
