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
deploy-template -Template_file $template_path"\win2019.core.json" -Template_var_file $template_var_path"\win2019.core.variables.json" -template_edition "core" -template_unattended $template_path"\autounattend.xml" -template_path_packer "c:\packer"
