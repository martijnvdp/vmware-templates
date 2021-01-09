Param($template_varfile,$template_unattended,$template_edition,[pscredential]$credential,$local_admin_pass)
# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer

. "$PSScriptRoot\function\publish-template.ps1"
#####
$template_file = $PSscriptroot + "\..\templates\Windows\2019\standard.json"
$template_varfile= $PSscriptroot+ "\..\templates\Windows\2019\standard.variables.json"
#$builder_var_file= $PSscriptroot + "\..\builders\vsphere-iso\vsphere-iso.variables.json"
$builder_var_file= $PSscriptroot + "\..\..\vars\vsphere-iso.variables.json"
$template_unattended= $PSscriptroot + "\..\templates\windows\2019\autounattend.xml"
$template_edition="standard"
#####

publish-template `
    -Template_os "windows" `
    -Credential $credential `
    -local_admin_pass $local_admin_pass `
    -Template_file $template_file  `
    -Template_var_file $template_varfile `
    -Builder_var_file $builder_var_file `
    -template_edition $template_edition `
    -template_unattended $template_unattended `
    -template_path_packer "c:\packer" 
#optional static ip
# -static_ip "1.2.3.4"
# -default_gw "1.2.3.1"
# -dns1 "8.8.8.8"
# -dns2 "8.8.4.4"
# -wsus_server "wsus.server.internal"
# -wsus_group "wsus_target_group"