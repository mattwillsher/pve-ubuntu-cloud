# pve-ubuntu-cloud
Script to download Ubuntu cloud images and set up a PVE KVM template

Quick script to dd ubuntu cloud images over a zvol so it can be used in Proxmox. Enables the serial console which can be monitored with qm terminal <vmid>. Without the serial console the VM hangs and consumes copious CPU.

Add a cloud-init CD (user-data, meta-data) to populate SSH keys and such. DHCP is required on the LAN the VM is attached to.

Read the script. Change the ZPOOL to where the VM block devices are stored. This has only been tested with zvols.

It's not quite finished, and I'm using the hardware to try Joyent SDC/Triton. Might pick it up in future. PRs, forks are welcome.

GPLv3 license.
