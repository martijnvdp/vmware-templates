# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer
#####
$template_path = $PSscriptroot + "\..\windows\2019"
$template_var_path = $PSscriptroot + "\..\..\vars"
#####
. "$PSScriptRoot\deploy-template.ps1"
if (!(test-path $template_var_path"\win2019.core.variables.json")) { $template_var_path = $template_path }
publish-template `
    -Template_file $template_path"\win2019.standard.json"  `
    -Template_var_file $template_var_path"\win2019.standard.variables.json" `
    -template_edition "standard" `
    -template_unattended $template_path"\autounattend.xml" `
    -template_path_packer "c:\packer"
#optional static ip
# -static_ip "1.2.3.4"
# -default_gw "1.2.3.1"
# -dns1 "8.8.8.8"
# -dns2 "8.8.4.4"