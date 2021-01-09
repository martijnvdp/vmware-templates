Param($template_varfile)
# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer
#####
$template_file = $PSscriptroot + "\..\ubuntu\20.4\server-iso-test.json"
$template_varfile= $PSscriptroot +"\..\..\vars\server-iso-test.variables.json"
#$builder_var_file= $PSscriptroot + "\..\builders\vsphere-iso\vsphere-iso.variables.json"
$builder_var_file= $PSscriptroot + "\..\..\vars\vsphere-iso.variables.json"
#####

publish-template `
    -Template_os "ubuntu" `
    -Template_file $template_file  `
    -Template_var_file $template_varfile `
    -Builder_var_file $builder_var_file `
    -template_path_packer "c:\packer" 