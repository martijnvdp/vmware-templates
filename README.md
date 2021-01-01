# Vmware templates with packer

Template automation using packer

## Getting Started

Use the deployment powershell scripts in deploy-scripts so you get asked for credentials 
with var files examples located in windows\2019
```
powershell -file deploy-scripts\deploy-2019-standard
powershell -file deploy-scripts\deploy-2019-core
powershell -file deploy-scripts\deploy-2019-all 
```

or manual:  \
windows 2019 template:\
packer build --var-file c:\Users\user\variables_win2019.json win2019.standard.json

## EFI
For EFI boot without custom image you need to reboot the vm and press a key manually \
work around boot delay 70s and the following boot_command : 
```
        "boot_wait": "70s",
        "boot_command": [
          "<tab><wait><enter><wait>",
          "a<wait>a<wait>a<wait>a<wait>a<wait>a<wait>"
        ],
```


### Deploy template function
deploy-template function in \templates\windows\2019\deploy-template.ps1 \
to use include this file in your script:  \

```
. "$PSScriptRoot\deploy-template.ps1"
$credential = get-credential
$winadmin_password = Read-Host 'Enter local admin password' 
deploy-template `
-Template_file ".\windows.2019.json" `
-Template_var_file ".\windows.2019.variables.json" `
-template_edition "standard" `
-template_unattended ".\autounattend.xml" `
-template_path_packer "c:\packer" `
-winadmin_password $winadmin_password `
-credential $credential `
-static_ip "1.1.4.2" `#optional static ip
-default_gw "1.1.4.1" #optional static ip
-dns1 "8.8.8.8" #optional static ip
-dns1 "8.8.4.4" #optional static ip
-wsus_server "internal_wsus_server" #optional wsus server
-wsus_group "wsus_target_group" #optional wsus target group

```



### variable files

To get the checksum value of windows iso's:\
use powershell get-filehash

To use windows filepath for the iso location use smb://
smb://someserver/share/windows.iso

### Ubuntu notes

packer will start a local webserver this must be accessible by the vm 
or use an iso with label cidata
example:

```
"cd_files": [
  "{{template_dir}}/http/meta-data",
  "{{template_dir}}/http/user-data"
],
"cd_label": "cidata",
"boot_command": [
 "ds=nocloud-net;s=/cidata/",
 
```

### Prerequisites

Required for windows: https://github.com/rgl/packer-provisioner-windows-update/releases
for the automated installing of windows updates

for ubuntu if not using the packer web server but iso an binary for creating the iso is needed:
for windows for example mkisofs , the supported commands are: xorriso, mkisofs, hdiutil, oscdimg)

### Issues
More than one disk on the same storage adapter gives :Invalid configuration for device '2'
https://github.com/hashicorp/packer/issues/10430

work around use a storage adapter for each disk

## Authors

* **M van der Ploeg** - *Initial work* - [martijn](https://github.com/martijnxd)

See also the list of [contributors](https://github.com/martijnxd/vmware-templates/contributors) who participated in this project.
