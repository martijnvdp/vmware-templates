# Powershell deployment script for packer
# 
# Ask for credentials vcenter and local admin password (should be the same as in unattended.xml)
# and pass them to packer
###
$credentials = get-credential
$var_file = ".\variables.json"
$build_file = ".\win2019.standard"
$winadmin_password = Read-Host 'enter local admin password'
packer build --var-file $var_file -var "vcenter_username=$($Credentials.username)"  -var "vcenter_password=$($Credentials.GetNetworkCredential().Password)"  -var "winadmin-password=$winadmin_password" $build_file