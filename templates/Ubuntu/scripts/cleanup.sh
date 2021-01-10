#!/bin/bash


#apt-get install -f -y python net-tools curl cloud-init python3-pip

# Install VMWare Guestinfo Cloud-init source, used by rancher
#curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -

# Reset Machine-ID
# http://manpages.ubuntu.com/manpages/bionic/man5/machine-id.5.html
# This is the equivalent of the SID in Windows
# Netplan also uses this as DHCP Identifier, causing multiple VMs from the same Image
# to get the same IP Address
rm -f /etc/machine-id

# Reset Cloud-init state
systemctl stop cloud-init
rm -rf /var/lib/cloud/
sudo systemctl start ssh
cloud-init clean -s -l

# actions for solving cutomazation issues icm vmware
# https://docs.vmware.com/en/VMware-Cloud-Assembly/services/Using-and-Managing/GUID-57D5D20B-B613-4BDE-A19F-223719F0BABB.html#example-procedureubuntu-1804-2
# remove cloud init to fix customization by vmware https://kb.vmware.com/s/article/54986
sleep 2m
#sudo rm /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
#sudo apt -y purge cloud-init && sudo apt -y autoremove
#sudo rm -rf /etc/cloud
#sudo rm /etc/netplan/00-installer-config.yaml
sudo dpkg-reconfigure cloud-init
sudo sed -i '/users\:/i disable_vmware_customization: true' /etc/cloud/cloud.cfg
sudo sed -i '/\[Unit\]/a After=dbus.service' /lib/systemd/system/open-vm-tools.service
sudo sed -i '/users\:/a disable_vmware_customization: true' /etc/cloud/cloud.cfg
sudo sed -i 's/D \/tmp/\#D \/tmp/' /usr/lib/tmpfiles.d/tmp.config
sudo sed -i 's/Host \*/aPermitRootLogin yes' /usr/lib/tmpfiles.d/tmp.config
echo -e "ubuntu\nubuntu|sudo passwd root"
sudo touch /etc/cloud/cloud-init.disabled
## start cron script
sudo cat >/home/ubuntu/re_init.sh <<EOF
#!/bin/bash
sudo rm -rf /etc/cloud/cloud-init.disabled
sudo cloud-init init
sleep 20
sudo cloud-init modules --mode config
sleep 20
sudo cloud-init modules --mode final
EOF
sudo chmod +x /home/ubuntu/re_init.sh
echo '@reboot ( sleep 90 ; sh /home/ubuntu/re_init.sh )' >> mycron
sudo crontab mycron

### start cleanup
# Add usernames to add to /etc/sudoers for passwordless sudo
users=("ubuntu" "cloudadmin")

for user in "${users[@]}"
do
cat /etc/sudoers | grep ^$user
RC=$?
if [ $RC != 0 ]; then
bash -c "echo \"$user ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"
fi
done

#grab Ubuntu Codename
codename="$(lsb_release -c | awk {'print $2}')"


#Stop services for cleanup
service rsyslog stop

#clear audit logs
if [ -f /var/log/audit/audit.log ]; then
cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
cat /dev/null > /var/log/lastlog
fi

#cleanup persistent udev rules
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
rm /etc/udev/rules.d/70-persistent-net.rules
fi

#cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

#cleanup current ssh keys
#rm -f /etc/ssh/ssh_host_*

#cat /dev/null > /etc/hostname

#cleanup apt
apt-get clean

#Clean Machine ID

truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

#Clean Cloud-init
cloud-init clean --logs --seed

#cleanup shell history
history -w
history -c