<br>
<br>

![image](https://github.com/DangerDrome/DangerOS/blob/fc4d13e57f73ae80edccb4f0f750be33b317193e/distro/rocky/media/brand/fedora-gdm-logo.png)
# An operating system for Visual Effects.
<br>
<br>

![image](https://github.com/user-attachments/assets/07a5b98d-4d78-440c-89d6-d7b06ba2b9f8)
<br>

![image](https://github.com/user-attachments/assets/64994912-1042-4594-af36-246bde255cdd)
<br>

![image](https://github.com/user-attachments/assets/773440d6-0410-4d22-b230-bf9e46a6c378)
<br>
<br>

# Features
#### DangerOS(Dangerous) is a spin on the Rocky Linux Operating System: Streamlined specifically for use in Visual Effects.


#### Features include
- [x] Ubiquitous Dark Mode
- [x] Windows 11 layout
- [ ] MacOS layout
- [x] A usable desktop (shortcuts, etc)
- [x] Useful default applications
- [x] Useful codecs for VFX
- [x] Remote Desktop features
- [x] Automated install
- [x] Step by Step install
- [ ] Ansible install

#### Apps include
- [x] Houdini
- [x] Unreal
- [x] Nuke
- [x] Maya
- [x] Blender
- [x] Resolve
- [x] OpenRV
- [x] Deadline
- [x] Natron
- [ ] 3ds Max
- [ ] After Effects
- [ ] Premiere
- [ ] Photoshop
<br>
<br>

# Automated Install
> [!WARNING]
> Use bash scripts at your own risk, read the code carefully before executing.
> We trust you have received the usual lecture from the local System
> Administrator. It usually boils down to these three things:
>
> - Respect the privacy of others.
> - Think before you type.
> - With great power comes great responsibility.

<br>

**1. Download this repository as a .zip file, extract, go into the /distro/rocky folder and run:**
```
sudo ./rocky_autoinstall_v02.sh
```
![image](https://github.com/user-attachments/assets/c5977059-e81e-4304-ac6a-f4e36a706613)

<br>
<br>
<br>

---

<br>
<br>
<br>






# Ansible install
> [!TIP]
> Lean more about ansible here: https://www.ansible.com/how-ansible-works/

**1. Playbook:**
```
comming soon...
```
<br>
<br>
<br>




# GPU passthrough 
**For running Virtual Machines.**
> [!TIP] 
> https://www.reddit.com/r/homelab/comments/b5xpua/the_ultimate_beginners_guide_to_gpu_passthrough/

<br>

**1. Configure the Grub:**

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

<br>

**2. VFIO Modules:**

```
nano /etc/modules

# Add the following to the 'modules' file:
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd

# Save & Exit nano(ctrl+o, ctrl+x)
```

<br>

**3. IOMMU interrupt remapping:**

```
echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf
```

<br>

**4. BlackListing Drivers:**

```
echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf
```

<br>

**5. Adding GPU to VFIO:**

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
<br>
<br>
<br>


# Step by step install
## Base system stuff



### 1. Download rocky linux
https://rockylinux.org/download | 
https://dl.rockylinux.org/pub/rocky/9/live/x86_64/Rocky-9-Workstation-x86_64-latest.iso

> [!TIP]
> The workstation ISO is recommeded for this install. 
> There are a sperate set of instructions for a minimal server install.
>
> 1. Download and install vendtoy on a usb thumb drive and copy the ISO to it. 
> 2. Set system to boot to thumbdrive in the system bios.
> 3. Follow the install instructions for the iso and ideally install onto an nvme drive on the system.
> 4. reboot the system and login as an admin/sudo user and open the terminal.

<br>

> [!WARNING]
> The renaming instructions are mostly done via the gnome terminal after the base OS install.
<br>

### 2. update system [R][F]
```
sudo dnf update -y
```
<br>

### 2. install Nano [R]
```
sudo dnf install nano -y
```
<br>

### 3. Install Git [R]
```
sudo dnf install git -y
```
<br>


### 3. Speed up dnf installs [R]
```
sudo nano /etc/dnf/dnf.conf

# Add the following lines:
max_parallel_downloads=10
fastestmirror=True
```
<br>


### 4. Disable SELinux [R][F]
```
sudo nano /etc/selinux/config 
```
Add this line:
- SELINUX=disabled
<br>


### 5. install tcsh [R][F]
```
sudo dnf install tcsh -y
```
<br>


### 6. install epel repo [R]
```
sudo dnf install epel-release -y
```
<br>


### 7. install aditional rpms (rpmfusion,mesa) [R]
download then double cliek to install
```
cd ~/Downloads
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/rpm/mesa-libGLU-9.0.1-6.el9.x86_64.rpm --output 'mesa-libGLU-9.0.1-6.el9.x86_64.rpm'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/rpm/rpmfusion-free-release-9.noarch.rpm --output 'rpmfusion-free-release-9.noarch.rpm'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/rpm/rpmfusion-nonfree-release-9.noarch.rpm --output 'rpmfusion-nonfree-release-9.noarch.rpm'
```
<br>


### 8. install flatpak & the flathub repo [R]
```
sudo dnf install flatpak -y
```
```
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
<br>



### 9. install timeshift (Backups) [R][F]
```
sudo dnf install timeshift -y
```
<br>

### 9. install fastfetch (System info fetcher) [R][F]
```
sudo dnf install fastfetch -y
```
<br>


### 10. Install mono icon fonts for the terminal [R][F]
```
cd /usr/share/fonts
sudo mkdir meslo-lgs-nf
cd meslo-lgs-nf
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font-mono/MesloLGSNerdFontMono-Bold.ttf --output 'MesloLGSNerdFontMono-Bold.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font-mono/MesloLGSNerdFontMono-BoldItalic.ttf --output 'MesloLGSNerdFontMono-BoldItalic.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font-mono/MesloLGSNerdFontMono-Italic.ttf --output 'MesloLGSNerdFontMono-Italic.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font-mono/MesloLGSNerdFontMono-Regular.ttf --output 'MesloLGSNerdFontMono-Regular.ttf'

sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font-propo/MesloLGSNerdFontPropo-Bold.ttf --output 'MesloLGSNerdFontPropo-Bold.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font-propo/MesloLGSNerdFontPropo-BoldItalic.ttf --output 'MesloLGSNerdFontPropo-BoldItalic.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font-propo/MesloLGSNerdFontPropo-Italic.ttf --output 'MesloLGSNerdFontPropo-Italic.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font-propo/MesloLGSNerdFontPropo-Regular.ttf --output 'MesloLGSNerdFontPropo-Regular.ttf'

sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font/MesloLGSNerdFont-Bold.ttf --output 'MesloLGSNerdFont-Bold.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font/MesloLGSNerdFont-BoldItalic.ttf --output 'MesloLGSNerdFont-BoldItalic.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font/MesloLGSNerdFont-Italic.ttf --output 'MesloLGSNerdFont-Italic.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/meslolgs-nerd-font/MesloLGSNerdFont-Regular.ttf --output 'MesloLGSNerdFont-Regular.ttf'
```
<br>


### 11. Install terminal customisations [R][F]
- Terminal theme, dot files, logo
```
cd ~/
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/terminal/gnome-terminal-profiles.dconf --output 'gnome-terminal-profiles.dconf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/terminal/.bashrc --output '.bashrc'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/terminal/.bash_aliases --output '.bash_aliases'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/terminal/logo_02.txt --output 'logo_02.txt'
exec bash
```
- load theme
```
load
c
ff
```
<br>



### 12. Install xrdp [R][F]
```
sudo dnf install xrdp -y
```
```
sudo systemctl start xrdp
```
```
sudo systemctl enable xrdp
```
```
sudo firewall-cmd --permanent --add-port=3389/tcp
```
```
sudo firewall-cmd --reload
```
<br>



### 12. Install Docker [R][F]
Rocky:
```
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
```
```
sudo dnf install docker-ce docker-ce-cli containerd.io -y
```
```
sudo systemctl enable --now docker
```
Fedora:
```
sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
```
```
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
```
sudo systemctl enable --now docker
```
<br>



### 12.1. Install Dockge (An easy way to run docker compose) [R][F]

#### Create directories that store your stacks and stores Dockge's stack
```
sudo mkdir -p /opt/stacks /opt/dockge
cd /opt/dockge
sudo curl https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml --output compose.yaml
sudo docker compose up -d
```
<br>

### 13. Install tailscale (VPN) [R][F]
follow command promt instructions
```
curl -fsSL https://tailscale.com/install.sh | sh
```
<br>


### 14. Install TrayScale (A tailscale GUI, has Wayland issues on Rocky, skip for now.) [F]
```
flatpak install dev.deedles.Trayscale -y
```
<br>


### 15. Install ntfs stuff (For mounting any ntfs drives) [R]
```
sudo dnf install ntfs-3g -y
```
<br>


### 16. Install pip (Ror python packages) [R][F]
```
sudo dnf install python3-pip -y
```
<br>


### 17. Install gnome-tweaks [R][F]
```
sudo dnf install gnome-tweaks -y
```
<br>


### 18. Install gnome-extensions [R][F]
Rocky:
```
sudo dnf install gnome-extensions-app-40.0-3.el9.x86_64 -y
```
Fedora:
```
sudo dnf install gnome-extensions-app-40.0-3.el9.x86_64 -y
```
<br>


### 19. Install Gnome Extension Manager [R][F]
```
flatpak install flathub com.mattjakeman.ExtensionManager -y
sudo flatpak override --env=GTK_THEME=Adwaita:dark com.mattjakeman.ExtensionManager
```
<br>


### 20. Install gnome extension CLI (Not sure if this is needed, still testing, skip for now)
```
sudo pip install --upgrade git+https://github.com/essembeh/gnome-extensions-cli -y
```
<br>


### 21. Install Nvidia Drivers [R][F]
You can use the **nvidia-smi** command after install/reboot to check the drivers 
```
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo 
sudo dnf install kernel-headers-$(uname -r) kernel-devel-$(uname -r) tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglvnd-devel acpid pkgconfig dkms -y
sudo dnf module install nvidia-driver:latest-dkms -y
echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf 
echo 'omit_drivers+=" nouveau "' | sudo tee /etc/dracut.conf.d/blacklist-nouveau.conf 
sudo dracut --regenerate-all --force 
sudo depmod -a
```
<br>
<br>
<br>
<br>

## General Apps

> [!TIP]
> You can search for flatpak apps via the command line: 
> ```
> flatpak search <app-name>
> ```


### 1. Install Resources (A Windows-like Task Manager) [R][F]
```
flatpak install flathub net.nokyan.Resources -y
sudo flatpak override --env=GTK_THEME=Adwaita:dark net.nokyan.Resources
```
<br>



### 2. Install Remmina (Remote Desktop Client) [R][F]
```
flatpak install --user flathub org.remmina.Remmina -y
```
<br>



### 3. Install Boxes (Simple Virtual machine software) [R][F]
```
sudo flatpak install org.gnome.Boxes -y
```
<br>


### 4. Install Calendar [R]
```
flatpak install flathub org.gnome.Calendar -y
sudo flatpak override --env=GTK_THEME=Adwaita:dark org.gnome.Calendar
```
<br>


### 5. Install Sticky Notes [R][F]
```
sudo flatpak install com.vixalien.sticky -y
```
<br>


### 6. Install Paper (very simple markdown notes) [R][F]
```
sudo flatpak install io.posidon.Paper -y
```
<br>



### 7. Install VSCode [R][F]
```
flatpak install flathub com.visualstudio.code -y
```
<br>


### 8. Install Obsidian [R][F]
```
flatpak install flathub md.obsidian.Obsidian -y
```
<br>


### 9. Install Celluloid [R][F]
```
flatpak install io.github.celluloid_player.Celluloid -y
```
<br>


### 10. Install ProtonPlus (for steam) [R][F]
```
flatpak install com.vysp3r.ProtonPlus -y
sudo flatpak override --env=GTK_THEME=Adwaita:dark com.vysp3r.ProtonPlus
```
<br>


### 11. Install Steam (for games/ nvidia testing) [R][F]
```
flatpak install com.valvesoftware.Steam -y
```
<br>



### 11. Install Github Desktop [R][F]
```
flatpak install io.github.shiftey.Desktop -y
```
<br>
<br>
<br>
<br>


## DCC apps

### 1. Install RV.
```
sudo dnf install python3-qt5 -y
sudo dnf install libXScrnSaver-devel-1.2.3-10.el9. -y 
sudo dnf install libGLU -y
sudo dnf install libnsl -y 
```
<br>

### 1. Install Natron (why? cli automation stuff)
```
sudo flatpak install fr.natron.Natron -y
```
<br>

### 2. Install Blender
```
sudo flatpak install flathub org.blender.Blender -y
```
<br>
<br>
<br>
<br>


## DE customisation 
<br>

### 1. Increase the screen sacle so you can actually read stuff.
In a terminal:
```
gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
```
<br>



### 1. Install Papirus Icons [R][F]
#### https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
Install it in the root folder:
```
sudo wget -qO- https://git.io/papirus-icon-theme-install | sh
```
<br>


### 2. Install Papirus Folder Colors [R][F]
#### https://github.com/PapirusDevelopmentTeam/papirus-folders
Install it in the root folder:
```
sudo wget -qO- https://git.io/papirus-folders-install | sh
```
Switch folder color to Grey:
```
papirus-folders -C grey --theme Papirus-Dark
```
<br>


### 3. Install custom Adwaita-dark themes  [R][F]
Download the themes zip:
#### https://github.com/DangerDrome/DangerOS/blob/main/themes.tar.xz
Extract and copy the folder to the themes directory:
```
cd /usr/share/themes
sudo cp -r /home/danger/Downloads/Adwaita-gray-dark 
```
