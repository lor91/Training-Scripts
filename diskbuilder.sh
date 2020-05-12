#!/bin/bash

##Create needed directory for storing VM storage disks

if [[ -d "$HOME/VMDisks" ]]
then
    echo "VMDisks directory exists on your filesystem, doing nothing."
else
    mkdir $HOME/VMDisks
    echo "VMDisks directory created, this can be found under $HOME/VMDisks"
fi

##Gather needed input from the user

virsh list --all

echo -n "The VM needs to be powered off. In the output above is the VM "shut off" (y/n)? "
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then

read -p "Which VM are you building a disk for? " vmname

read -p "Give the disk a unique name: " diskname

read -p "what size does the disk need to be in mb? (eg 8192 for an 8gb disk): " disksize

read -p "how should the disk be designated in /dev/? Only answer as you would expect to see in the directory /dev/* IE sda or vdb: " targetdev

##Build and attach the disks

dd if=/dev/zero of=$HOME/VMDisks/$diskname.img bs=1M count=$disksize

touch $HOME/VMDisks/$diskname.xml

echo "<disk type='file' device='disk'> 
   <driver name='qemu' type='raw' cache='none'/> 
   <source file='/home/mike/VMDisks/$diskname.img'/> 
   <target dev='$targetdev'/> 
</disk>" >>  $HOME/VMDisks/$diskname.xml

virsh attach-device --config $vmname $HOME/VMDisks/$diskname.xml

echo "If no failures occurred then the disk should now be attached."
echo "To remove the disk run the following command:"
echo "virsh detach-device --config $vmname $HOME/VMDisks/$diskname.xml"
echo "The disk files can then be deleted. They can be found at $HOME/VMDisks/$diskname.xml and $HOME/VMDisks/$diskname.img"

else 
echo "VM is not powered off, run "virsh shutdown VMNAME" to power off the VM"
fi
