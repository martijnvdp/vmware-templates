# Vmware templates with packer

Template automation using packer icm vsphere-iso

## Getting Started

Use the deployment powershell scripts in deploy-scripts so you get asked for credentials 
with var files examples located in windows\2019
```
powershell -file deploy-scripts\deploy-2019-standard
powershell -file deploy-scripts\deploy-2019-core
powershell -file deploy-scripts\deploy-all 
```

or manual:  \
(for windows its better to use the deployment script due the autounattend.xml customization) \
example ubuntu 20.04 template:
```

packer build -force --var-file templates\ubuntu\20.4\server-efi.variables.json" \
                     --var-file builders\vsphere-iso\vsphere-iso.variables.json \
                     -var "vcenter_username=username" \
                     -var "vcenter_password=password" \
                     templates\ubuntu\20.4\server-efi.json
```    

## EFI windows 2019
For Windows EFI boot without custom image you need to reboot the vm and press a key manually \
work around boot delay 70s and the following boot_command : 
```
        "boot_wait": "70s",
        "boot_command": [
          "<tab><wait><enter><wait>",
          "a<wait>a<wait>a<wait>a<wait>a<wait>a<wait>"
        ],
```
## EFI Ubuntu 20.04 seed from packer http server
for ubuntu 20.04 the bootcmds need to be quoted after autoinstall \
working efi boot:
```
"boot_command": [
        "<esc><wait>",
        "<esc><wait>",
        "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"<enter><wait>",
        "initrd /casper/initrd<enter><wait>",
        "boot<enter>"
      ],
```
## EFI Ubuntu 20.04 seed from iso created during deployment

for this an iso creator is needed ,for windows for example mkisofs \
the supported commands are: xorriso, mkisofs, hdiutil, oscdimg)


```
      "boot_command": [
        "<esc><wait>",
        "<esc><wait>",
        "linux /casper/vmlinuz --- autoinstall ds=nocloud;seedfrom=/cidata/",
        "<enter><wait>",
        "initrd /casper/initrd<enter><wait>",
        "boot<enter>"
      ],
      "cd_files": [
      "{{template_dir}}/http/meta-data",
      "{{template_dir}}/http/user-data"
      ],
      "cd_label": "cidata",
```

## EFI Centos 8 kickstart from iso created during deployment

need to specify cdrom device:

```
"boot_command": ["e<down><down><end><bs><bs><bs><bs><bs>text ks=cdrom:/dev/sr1:/ks.cfg<leftCtrlOn>x<leftCtrlOff>"],
      "cd_files": [
      "{{template_dir}}/http/ks.cfg"
      ],
      "cd_label": "cidata",
      "boot_wait": "3s",
```      
## Static ip or custom wsus server settings
static ip or custom wsus settings can be set from the windows deployment scripts
```
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

packer will start a local webserver this must be accessible by the VM  so you have to open the port in the local firewall
\
Or use an iso with label cidata
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
