```
         .://:`              `://:.            root@dangerpi 
       `hMMMMMMd/          /dMMMMMMh`          ------------- 
        `sMMMMMMMd:      :mMMMMMMMs`           OS: Proxmox VE 7.2-7 aarch64 
`-/+oo+/:`.yMMMMMMMh-  -hMMMMMMMy.`:/+oo+/-`   Host: Raspberry Pi 4 Model B Rev 1.5 
`:oooooooo/`-hMMMMMMMyyMMMMMMMh-`/oooooooo:`   Kernel: 6.1.21-v8+ 
  `/oooooooo:`:mMMMMMMMMMMMMm:`:oooooooo/`     Uptime: 8 mins 
    ./ooooooo+- +NMMMMMMMMN+ -+ooooooo/.       Packages: 859 (dpkg) 
      .+ooooooo+-`oNMMMMNo`-+ooooooo+.         Shell: bash 5.1.4 
        -+ooooooo/.`sMMs`./ooooooo+-           Resolution: 3840x2160 
          :oooooooo/`..`/oooooooo:             Terminal: /dev/pts/0 
          :oooooooo/`..`/oooooooo:             CPU: BCM2835 (4) @ 1.800GHz 
        -+ooooooo/.`sMMs`./ooooooo+-           Memory: 1114MiB / 7812MiB 
      .+ooooooo+-`oNMMMMNo`-+ooooooo+.
    ./ooooooo+- +NMMMMMMMMN+ -+ooooooo/.                               
  `/oooooooo:`:mMMMMMMMMMMMMm:`:oooooooo/`                             
`:oooooooo/`-hMMMMMMMyyMMMMMMMh-`/oooooooo:`
`-/+oo+/:`.yMMMMMMMh-  -hMMMMMMMy.`:/+oo+/-`
        `sMMMMMMMm:      :dMMMMMMMs`
       `hMMMMMMd/          /dMMMMMMh`
         `://:`              `://:`
```

#  1. Install via usb as boot

**Remove the high spec gpu and add a shitty one**

> [!TIP] https://enterprise.proxmox.com/iso/proxmox-ve_8.0-2.iso

**Install ProxMox via console (not graphical)**

**After install, swap back to the high spec GPU**

---
#  2. Bypass the GPU

**Make ProxMox bypass the gpu, full notes here:**

>[!tldr] https://www.reddit.com/r/homelab/comments/b5xpua/the_ultimate_beginners_guide_to_gpu_passthrough/


**Configure the Grub**

```
nano /etc/default/grub

# Change this line:
GRUB_CMDLINE_LINUX_DEFAULT="quiet"

# To this line:
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on"

# Or with additional commands:
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt pcie_acs_override=downstream,multifunction nofb nomodeset video=vesafb:off,efifb:off"

# Save & Exit

update-grub
```


**VFIO Modules:**

```
nano /etc/modules

# Add the following to the 'modules' file:
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd

# Save & Exit nano(ctrl+o, ctrl+x)
```


**IOMMU interrupt remapping**

```
echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf
```


**BlackListing Drivers**

```
echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf
```


**Adding GPU to VFIO**

```
lspci -v | grep NVIDIA

# Find you GPU Number and run the following, for example:
lspci -n -s 01:00

# Take note of the vendor id codes: **10de:1b81** and **10de:10f0**.
# Now we add the GPU's vendor id's to the VFIO, for example:
echo "options vfio-pci ids=10de:1b81,10de:10f0 disable_vga=1"> /etc/modprobe.d/vfio.conf

# Finally, run this:
update-initramfs -u

# restart
reset
```


---

#  3. Messing with clusters

**Remove or reset cluster configuration on a node**

```
# ssh into the node, then:
systemctl stop pve-cluster corosync  
pmxcfs -l  
rm /etc/corosync/*  
rm /etc/pve/corosync.conf  
killall pmxcfs  
systemctl start pve-cluster

```

**Remove a node from the cluster**
```
# List current nodes:
pvecm nodes

# delete the 'node'
pvecm delnode <nodename>

# OR delete node by name:
pvecm delnode <nodename>
pvecm status

# Then delete the folder for that node:
rm -rf /etc/pve/nodes/<nodename>

```
