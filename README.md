# Training-Scripts
Scripts developed for own use and training

The two scripts were intended to simplify a relatively common task when creating and deprovisioning kvm-libvirt VMs frequently.

Initially both scripts ended up very simple. The DeleteVM script is still very simple and most work went into the disk builder.  

virsh-createVMdisk.sh is designed to simplify the creation of additional disks for KVM/Libvirt VMs and is intended to be useable on any Linux host. This was also built with the intention of having close to 100% error handling both for practicality and as a learning tool. 
