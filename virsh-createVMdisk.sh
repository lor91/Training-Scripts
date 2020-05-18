#!/bin/bash

##Create needed directory for storing VM storage disks

if [[ -d "$HOME/VMDisks" ]]
	then
    		echo "VMDisks directory exists on your filesystem, doing nothing."
	else
    		mkdir $HOME/VMDisks
    		echo "VMDisks directory created, this can be found under $HOME/VMDisks"
fi

##Check if VM is read for attaching disk
##This will be improved in future by reading the output of the list --all command and killing the script automatically if needed

virsh list --all
        echo -n "The VM needs to be powered off. In the output above is the VM "shut off" (y/n)? "
        read answer

while [[ $answer != '*' ]]; do

        case "$answer" in
                y|Y ) echo "OK" && break ;;
                n|N ) echo "Power off the VM using 'virsh destroy VMNAME' then run this script again." && exit ;;
                * )   read -p "The VM needs to be powered off. In the output above is the VM 'shut off' (y/n)? " answer ;;
        esac
done

##Ensure the VM exists

read -p "Which VM are you creating a disk for? (case-sensitive) " vmname

virsh list --all | grep -q $vmname

if [ "$?" = "1" ]; then
	echo "That VM doesn't exist, please try again, remember the VMName is case-sensitive."
	exit
fi

if [ "$?" = "0" ]; then

##Gather needed input

read -p "Give the disk a unique name: " diskname
read -p "what size does the disk need to be in mb? (eg 8192 for an 8gb disk): " diskinput

##Read and clean the disksize response from user to be numeric only

disksize=$(echo "$diskinput" | sed 's/[^0-9]*//g')

while [[ $disksize -eq '0' ]]; do
	read -p "Cannot create a 0mb disk, you need to enter a valid disk size in mb: " disksize
		if [[ $disksize == '0' ]]; then read -p "Cannot create a 0mb disk, you need to enter a valid disk size in mb: " disksize 
		else echo "OK" && break; fi
done

##Clean the input again if required

disksizeclean=$(echo "$disksize" | sed 's/[^0-9]*//g')

echo "Will create new disk of size $disksizeclean MBs"

##Choose letter assignment for new disk drive in /dev/

read -p "how should the disk be designated in /dev/? Only answer as you would expect to see in the directory /dev/* IE sda or vdb: " targetdev

while [[ $targetdev != 'sd[a-z]|vd[a-z]' ]]; do

case "$targetdev" in
        sd[a-z]|vd[a-z] ) echo "OK" && break ;;
        * ) read -p "format invalid, the only acceptable response is vd[a-z] or sd[a-z]. Try again: " targetdev ;;
esac
done

##Build and attach the disks

dd if=/dev/zero of=$HOME/VMDisks/$diskname.img bs=1M count=$disksizeclean

touch $HOME/VMDisks/$diskname.xml

echo "<disk type='file' device='disk'> 
   <driver name='qemu' type='raw' cache='none'/> 
   <source file='$HOME/VMDisks/$diskname.img'/> 
   <target dev='$targetdev'/> 
</disk>" >>  $HOME/VMDisks/$diskname.xml

virsh attach-device --config $vmname $HOME/VMDisks/$diskname.xml

fi

if [ "$?" = "0" ]; then

echo "The disk should now be attached."
echo "To remove the disk run the following command:"
echo "virsh detach-device --config $vmname $HOME/VMDisks/$diskname.xml"
echo "The disk files can then be deleted. They can be found at $HOME/VMDisks/$diskname.xml and $HOME/VMDisks/$diskname.img"

else 

##Future build will add prompt to ask user if they want to remove the created disk files or not

echo "The command could not complete, check the VM name and try again.

Cleaning erroneous disk files..."

rm -f $HOME/VMDisks/$diskname.xml
rm -f $HOME/VMDisks/$diskname.img

fi
