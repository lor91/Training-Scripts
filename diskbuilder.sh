#!/bin/bash

virsh list --all

echo -n "The VM needs to be powered off. In the output above is the VM "shut off" (y/n)? "
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then

read -p "Which VM are you building a disk for? " vmname

read -p "Give the disk a unique name: " diskname

read -p "what size does the disk need to be in mb? (eg 8192 for an 8gb disk): " disksize

read -p "how should the disk be designated in /dev/? Only answer as you would expect to see in the directory /dev/* IE sda or vdb: " targetdev

dd if=/dev/zero of=/home/mike/VMDisks/$diskname.img bs=1M count=$disksize

touch /home/mike/VMDisks/$diskname.xml

echo "<disk type='file' device='disk'> 
   <driver name='qemu' type='raw' cache='none'/> 
   <source file='/home/mike/VMDisks/$diskname.img'/> 
   <target dev='$targetdev'/> 
</disk>" >>  /home/mike/VMDisks/$diskname.xml

virsh attach-device --config $vmname /home/mike/VMDisks/$diskname.xml

echo "If no failures occurred then the disk should now be attached."
echo "To remove the disk run the following command:"
echo "virsh detach-device --config $vmname /home/mike/VMDisks/$diskname.xml"
echo "The disk files can then be deleted. They can be found at /home/mike/VMDisks/$diskname.xml and /home/mike/VMDisks/$diskname.img"

else 
echo "VM is not powered off, run "virsh shutdown VMNAME" to power off the VM"
fi
