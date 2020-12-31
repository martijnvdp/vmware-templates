# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer
#####
$template_path = $PSscriptroot + "\..\windows\2019"
$template_var_path = $PSscriptroot + "\..\..\vars"
#####
. "$PSScriptRoot\function\publish-template.ps1"
$credential = Get-Credential
$localadmin_password = Read-Host 'Enter local admin password'
if (!(test-path $template_var_path"\win2019.core.variables.json")) { $template_var_path = $template_path }
publish-template -Template_file $template_path"\win2019.core.json" -Template_var_file $template_var_path"\win2019.core.variables.json" -template_os "windows" -template_edition "core" -template_unattended $template_path"\autounattend.xml" -template_path_packer "c:\packer" -credential $credential -winadmin_password $localadmin_password
publish-template -Template_file $template_path"\win2019.standard.json" -Template_var_file $template_var_path"\win2019.standard.variables.json" -template_os "windows" -template_edition "standard" -template_unattended $template_path"\autounattend.xml" -template_path_packer "c:\packer" -credential $credential -winadmin_password $localadmin_password
