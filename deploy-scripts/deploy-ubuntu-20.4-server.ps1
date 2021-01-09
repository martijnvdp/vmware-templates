Param($template_varfile)
# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer

. "$PSScriptRoot\function\publish-template.ps1"
#####
$template_file = $PSscriptroot + "\..\templates\ubuntu\20.4\server-efi.json"
$template_varfile= $PSscriptroot+ "\..\templates\ubuntu\20.4\server-efi.variables.json"
#$builder_var_file= $PSscriptroot + "\..\builders\vsphere-iso\vsphere-iso.variables.json"
$builder_var_file= $PSscriptroot + "\..\..\vars\vsphere-iso.variables.json"
#####

publish-template `
    -Template_os "ubuntu" `
    -Template_file $template_file  `
    -Template_var_file $template_varfile `
    -Builder_var_file $builder_var_file `
    -template_path_packer "c:\packer" 