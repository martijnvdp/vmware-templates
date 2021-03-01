Param([pscredential]$credential, $local_admin_pass)
# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer

. "$PSScriptRoot/function/publish-template.ps1"
#####
$deploy_params = @{
    template_file        = $PSscriptroot + "/../templates/Windows/2019/STANDARD/Standard.json"
    template_var_file    = $PSscriptroot + "/../templates/Windows/2019/STANDARD/Standard.variables.json"
    builder_var_file     = $PSscriptroot + "/../../vars/vsphere-iso.variables.json"
    template_path        = $PSscriptroot + "/../templates/Windows/2019/STANDARD"
    autounattend_file    = $PSscriptroot + "/../templates/Windows/2019/autounattend/standard-autounattend.xml"
    path_packer          = "/usr/bin/packer"
}
#####
#if ($Islinux -and !(test-path "/$($iso_url.trim("file://"))")) {python3 $PSscriptroot/deploy-scripts/function/autodownload-windows2019eval.py}
if (!(test-path $deploy_params.builder_var_file)) { $deploy_params.builder_var_file = $PSscriptroot + "/../builders/vsphere-iso/vsphere-iso.variables.json" } 
publish-template @deploy_params -Credential $credential -local_admin_pass $local_admin_pass
