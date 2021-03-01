Param($template_varfile, [pscredential]$credential)
# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer

. "$PSScriptRoot/function/publish-template.ps1"
#####
$deploy_params = @{
    template_file        = $PSscriptroot + "/../templates/Alpine/3.13.1/server.json"
    template_var_file    = $PSscriptroot + "/../templates/Alpine/3.13.1/server.variables.json"
    builder_var_file     = $PSscriptroot + "/../../vars/vsphere-iso.variables.json"
    path_packer          = "c:/packer"
}
#####
if (!(test-path $deploy_params.builder_var_file)) { $deploy_params.builder_var_file = $PSscriptroot + "/../builders/vsphere-iso/vsphere-iso.variables.json" } 
publish-template @deploy_params -Credential $credential