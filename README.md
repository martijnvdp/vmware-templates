# Vmware templates with packer

Template automation using packer

## Getting Started

Use the deployment powershell script windows\2019\deploy-2019-template.ps1 so you get asked for credentials 

or manual:  \
windows 2019 template:\
packer build --var-file c:\Users\user\variables_win2019.json win2019.standard.json

## EFI
For efi secure boot you need to press a key manually or use a custom iso as descibed here:
https://taylor.dev/removing-press-any-key-prompts-for-windows-install-automation/  \

### variable files

To get the checksum value of windows iso's:\
use powershell get-filehash

To use windows filepath for the iso location use smb://
smb://someserver/share/windows.iso

### Ubuntu notes

packer will start a local webserver this must be accessible by the vm 

### Prerequisites

Required for windows: https://github.com/rgl/packer-provisioner-windows-update/releases
for the automated installing of windows updates


## Authors

* **M van der Ploeg** - *Initial work* - [martijn](https://github.com/martijnxd)

See also the list of [contributors](https://github.com/martijnxd/vmware-templates/contributors) who participated in this project.
