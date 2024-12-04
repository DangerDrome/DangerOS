![image](https://github.com/user-attachments/assets/4c10df54-2808-4768-a96b-ff5613d9de40)


# Fedora Install Guide

### Install via the Network Installer.
- Available here: https://alt.fedoraproject.org/
Do all the basic steps (language, layout, time&date, partition, etc)
[Important Step] In Software Selection Menu tick "Minimal Install" and deselect all other options
- After Installation, Reboot and login to the shell (tty).
<br>


### Update. 
```
dnf update -y
dnf install nano -y
```
<br>
 
### Enable ssh and login from another machine.
```
# Open the ssh config file:
nano /etc/ssh/ssh_config

# Add this line:
PermitRootLogin Yes
```
<br>

### RPM Fusion.
- RPM Fusion repositories provides some useful applications (Eg: VLC and other stuff)
- Repository: https://rpmfusion.org/Configuration
```
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf makecache
```
<br>

### NVIDIA Drivers.
- After install & reboot you can check that it worked by running: **nvidia-smi** 
Check that you have a card installed:
```
lspci | grep -Ei 'VGA|3D'
```
Refesh any packages:
```
sudo dnf update --refresh
```
Install headers and Dev tools:
```
sudo dnf install kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig -y
```
Install Drivers (x2)
```
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda -y
sudo dnf install nvidia-vaapi-driver libva-utils vdpauinfo -y
```
```
sudo reboot
```
<br>

### Setup the Graphical User Interface (Gnome).
```
sudo dnf install @base-x gnome-shell gnome-console nautilus firefox
```
- @base-x - base for DE ('@' in dnf specifies a group )
- gnome-shell - Pulls minimal dependencies for Gnome DE
- gnome-console - Terminal
- nautilus - File Manager
- firefox - Web Browser
<br>

### Nautilus Python.
```
sudo dnf install nautilus-python -y
```
<br>

### Add Extensions.
Open the Terminal and run:
```
sudo dnf install gnome-tweaks @development-tools
```
- gnome-tweaks - To tweak gnome
- @development-tools - provides basic dev tools. Why should i install development-tools? Installing gnome extensions from browser wont work until you install 'unzip'. Installing @devopment-tools will pull unzip & all necessary tools.
<br>

### Added DE functionality.
To add 'Open in Terminal' option for nautilus, user-directories in sidebar, thumbnails:
```
sudo dnf install gnome-terminal-nautilus xdg-user-dirs xdg-user-dirs-gtk ffmpegthumbnailer
```
- gnome-terminal-nautilus - adds 'Open in Terminal' option
- xdg-user-dirs, xdg-user-dirs-gtk - adds user directories in nautilus sidebar
- ffmpegthumbnailer - provides thumbnails for nautilus
<br>

### Multimedia Support.
Installing VLC will pull all the multimedia codecs (requires RPM Fusion repo):
```
sudo dnf install vlc -y
```
<br>

### Some useful default Applications.
```
$ sudo dnf install gnome-disk-utility gnome-calculator gnome-calendar gnome-system-monitor gnome-text-editor evince file-roller -y
```
- evince - document viewer
- file-roller - archive manager
<br>

### Make Fedora boot into GUI by default
```
sudo systemctl set-default graphical.target
reboot
```
<br>

###  Resize the root logical volume as 15gigs is too small
```
# List volumes
lsblk -o NAME,FSTYPE,SIZE,LABEL,FSSIZE,FSUSE%,MOUNTPOINTS
# Extend the volume by 100gigs
sudo lvextend /dev/mapper/fedora_work0060-root -L 100G
# Add to the root 
sudo xfs_growfs /dev/mapper/fedora_work0060-root 
```
<br>

###  Networking stuff
```
sudo dnf install gvfs-smb -y 
```
<br>

<br>       
<br>

# Batch Install Script (WIP)
```
# Install el9 packages:

sudo dnf install -y \
--setopt=install_weak_deps=False \
ImageMagick \
timeshift \
ffmpeg \
fastfetch \
vlc \
gh \
gnome-tweaks \
gnome-extensions-app \
keepassxc \
mediainfo \
tldr \
xdg-desktop-portal-gnome


# Install flatpak packages:

sudo flatpak install -y \
com.mattjakeman.ExtensionManager \
io.github.shiftey.Desktop \
org.deluge_torrent.deluge \
com.mattjakeman.ExtensionManager \
net.nokyan.Resources \
org.remmina.Remmina \
org.gnome.Calendar \
com.vixalien.sticky \
com.visualstudio.code \
md.obsidian.Obsidian \
io.github.celluloid_player.Celluloid \
com.vysp3r.ProtonPlus \
com.valvesoftware.Steam \
fr.handbrake.ghb \
org.kde.krita \
com.github.tchx84.Flatseal


# Make stuff Dark:

gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

```
