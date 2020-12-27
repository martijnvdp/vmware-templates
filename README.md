# Vmware templates with packer

Template automation using packer

## Getting Started

windows 2019 template:\
packer build --var-file c:\Users\user\variables_win2019.json win2019.standard.json

### variable files

To get the checksum value of windows iso's:\
use powershell get-filehash

To use windows filepath for the iso location use smb://
smb://someserver/share/windows.iso

### Ubuntu notes

packer will start a local webserver this must be accessible by the vm 

### Prerequisites

Requiered for windows: https://github.com/rgl/packer-provisioner-windows-update/releases
for the automated installing of windows updates


## Authors

* **M van der Ploeg** - *Initial work* - [martijn](https://github.com/martijnxd)

See also the list of [contributors](https://github.com/martijnxd/vmware-templates/contributors) who participated in this project.
