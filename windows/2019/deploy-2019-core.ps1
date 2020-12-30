# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password
# and pass them to packer
#####vars
. "$PSScriptRoot\deploy-template.ps1"
deploy-template -Template_file ".\win2019.core.json" -Template_var_file ".\win2019.core.variables.json" -template_edition "core" -template_unattended ".\autounattend.xml" -template_path_packer "c:\packer"
