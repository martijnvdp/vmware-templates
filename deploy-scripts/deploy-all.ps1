$credential=Get-Credential
$local_admin_pass=Read-Host "Enter local administrator password"
$params = @{credential=$credential;local_admin_pass=$local_admin_pass}
& "$psscriptroot\deploy-2019-core.ps1"  @params
& "$psscriptroot\deploy-2019-standard.ps1" @params
& "$psscriptroot\deploy-ubuntu-20.4.ps1" @params
& "$psscriptroot\deploy-centos-8.ps1" @params