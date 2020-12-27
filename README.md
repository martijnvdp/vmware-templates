# vmware-templates
requiered for windows: https://github.com/rgl/packer-provisioner-windows-update/releases

usage
packer build --var-file c:\Users\user\variables_win2019.json win2019.standard.json

checksum windows iso's:
use powershell get-filehash

filepath iso on share (auto upload to vmware)
smb://someserver/share/windows.iso

ubuntu:
packer will start a local webserver this must be accessible by the vm
