# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer
#####
$template_path = $PSscriptroot + "\..\ubuntu\20.4"
$template_var_path = $PSscriptroot + "\..\..\vars"
#####
. "$PSScriptRoot\function\publish-template.ps1"
if (!(test-path $template_var_path"\ubuntu-20.04-server.variables.json")) { $template_var_path = $template_path }
publish-template `
    -template_os "ubuntu" `
    -Template_file $template_path"\ubuntu-20.04-server-efi-http.json"  `
    -Template_var_file $template_var_path"\ubuntu-20.04-server-efi-http.variables.json" `
    -template_path_packer "c:\packer" 