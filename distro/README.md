# Fedora Install Guide

### Install via the Network Installer.
- Available here: https://alt.fedoraproject.org/
Do all the basic steps (language, layout, time&date, partition, etc)
[Important Step] In Software Selection Menu tick "Minimal Install" and deselect all other options
- After Installation, Reboot and login to the shell (tty).
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

### Make Fedora boot into GUI by default
```
sudo systemctl set-default graphical.target
reboot
```
<br>

### Login to the Desktop Environment.
Open the Terminal and run:
```
sudo dnf install gnome-tweaks @development-tools
```
- gnome-tweaks - To tweak gnome
- @development-tools - provides basic dev tools. Why should i install development-tools? Installing gnome extensions from browser wont work until you install 'unzip'. Installing @devopment-tools will pull unzip & all necessary tools.
<br>

### Multimedia Support.
Installing VLC will pull all the multimedia codecs (requires RPM Fusion repo):
```
sudo dnf install vlc -y
```
<br>

### Added functionality.
To add 'Open in Terminal' option for nautilus, user-directories in sidebar, thumbnails:
```
sudo dnf install gnome-terminal-nautilus xdg-user-dirs xdg-user-dirs-gtk ffmpegthumbnailer
```
- gnome-terminal-nautilus - adds 'Open in Terminal' option
- xdg-user-dirs, xdg-user-dirs-gtk - adds user directories in nautilus sidebar
- ffmpegthumbnailer - provides thumbnails for nautilus
<br>

### Some useful default Applications.
```
$ sudo dnf install gnome-calculator gnome-system-monitor gnome-text-editor evince file-roller
```
- gnome-text-editor - text editor
- evince - document viewer
- file-roller - archive manager
<br>
<br>
<br>

# Example Batch Install Script.
```
sudo dnf install -y \
--setopt=install_weak_deps=False \
gnome-shell \
ffmpegthumbnailer \
file-roller \
gnome-console \
gnome-software \
gnome-extensions-app \
gnome-system-monitor \
gnome-text-editor \
libavcodec-freeworld \
nautilus \
xdg-user-dirs \
xdg-user-dirs-gtk

```
