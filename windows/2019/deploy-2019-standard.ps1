# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer
#####vars
. "$PSScriptRoot\deploy-template.ps1"
deploy-template -Template_file ".\win2019.standard.json" -Template_var_file ".\win2019.standard.variables.json" -template_edition "standard" -template_unattended ".\autounattend.xml" -template_path_packer "c:\packer"
