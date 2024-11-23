```
                                                             ■██████■     
                                                          ████████████■   
                                                 ███████ █████    ███     
                                          █████  ███     ████    ███      
                            ■          █████  ████████████████  ████      
                           ███   ███  █████    ██████    ████ █████       
            ■█████████    ███ █   ██ ██████     ███   ███████████         
         ░▒██████████████ ██  ██ ███ █████ █████████████████████          
       ░▒███████░░░▒██████████████████████  █████      ████ █████         
       ░███████    ▒██████████████ ███ ███████        █████  ██████       
        ░████     ░██████░░▒█████  █▓  ████          ████     █████       
        ░█████    ░██████   ░████  ▒                  ████      █████     
     ░▒█████     ░██████     ███   ░                 ███        ██████    
     ░██████      ░█████      ▓                     ████■          ██████ 
     ░█████    ░███████       ■                                     █████ 
     ░████    ░██████                                                 ██████■ ®
     ░████  ░███████                                                          
   ░▓████░████████                                                    ░█▀█░█▀▀
   ░▓███████████                                                      ░█░█░▀▀█
   ░▓███████                                                          ░▀▀▀░▀▀▀
 ░▓███████                                                            
 ■▓██▒░░░                
 ░░▒
```
# DangerOS
#### DangerOS(Dangerous) is a spin on the Rocky Linux Operating System: Streamlined specifically for use in Visual Effects.


#### Features included:
- [x] Ubiquitous Dark Mode
- [x] Windows 11 layout
- [ ] MacOS layout
- [x] A usable desktop (shortcuts, etc)
- [x] Useful default applications
- [x] Useful codecs for VFX
- [x] Remote Desktop features
- [ ] Ansible install
- [ ] Automated install
- [x] Step by Step install

#### Apps included:
- [x] Houdini
- [x] Unreal
- [x] Nuke
- [x] Maya
- [x] Blender
- [x] Resolve
- [x] OpenRV
- [x] Deadline
- [ ] Natron
- [ ] 3ds Max
- [ ] After Effects
- [ ] Premiere
- [ ] Photoshop
<br>
<br>

# Screenshots
![image](https://github.com/user-attachments/assets/4dd916f9-f509-42e3-9b36-a1af57a5d144)






# Ansible install
### Playbook:
```
comming soon...
```
> [!TIP]
> Lean more about ansible here: https://www.ansible.com/how-ansible-works/
<br>
<br>
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
### Run the following in a shell:
```
comming soon...
```

<br>
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

> [!WARNING]
> The renaming instructions are mostly done via the gnome terminal after the base OS install.
<br>


### 2. install Nano
```
sudo dnf install nano -y
```
<br>


### 3. Speed up dnf installs
```
sudo nano /etc/dnf/dnf.conf

# Add the following lines:
max_parallel_downloads=10
fastestmirror=True
```
<br>


### 4. Disable SELinux
```
sudo nano /etc/selinux/config 
```
Add this line:
- SELINUX=disabled
<br>


### 5. install tcsh
```
sudo dnf install tcsh -y
```
<br>


### 6. install epel repo
```
sudo dnf install epel-release -y
```
<br>


### 7. install aditional rpms (rpmfusion,mesa)
download then double cliek to install
```
cd ~/Downloads
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/rpm/mesa-libGLU-9.0.1-6.el9.x86_64.rpm --output 'mesa-libGLU-9.0.1-6.el9.x86_64.rpm'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/rpm/rpmfusion-free-release-9.noarch.rpm --output 'rpmfusion-free-release-9.noarch.rpm'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/rpm/rpmfusion-nonfree-release-9.noarch.rpm --output 'rpmfusion-nonfree-release-9.noarch.rpm'
```
<br>


### 8. install flatpak repo
```
sudo dnf install flatpak -y
```
```
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
<br>



### 9. install timeshift (backups)
```
sudo dnf install timeshift -y
```
<br>


### 10. Install mono icon fonts for the terminal 

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


### 11. Download terminal color scheme
Get it from the DangerOS/themes folder:
- gnome-terminal-profiles.dconf
<br>



### 12. Install xrdp
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


### 13. Install tailscale (VPN)
follow command promt instructions
```
curl -fsSL https://tailscale.com/install.sh | sh
```
<br>


### 14. Install TrayScale (a tailscale GUI)
```
flatpak install dev.deedles.Trayscale -y
```
<br>


### 15. Install ntfs stuff(so you can mount ntfs drives)
```
sudo dnf install ntfs-3g -y
```
<br>


### 16. Install pip (for python packeages)
```
sudo dnf install python3-pip -y
```
<br>


### 17. Install gnome-tweaks
```
sudo dnf install gnome-tweaks -y
```
<br>


### 18. Install gnome-extensions
```
sudo dnf install gnome-extensions-app-40.0-3.el9.x86_64 -y
```
<br>


### 19. Install Gnome Extension Manager
```
flatpak install flathub com.mattjakeman.ExtensionManager -y
sudo flatpak override --env=GTK_THEME=Adwaita:dark com.mattjakeman.ExtensionManager
```
<br>


### 20. Install gnome extension CLI (no sure if this is required, still testing)
```
sudo pip install --upgrade git+https://github.com/essembeh/gnome-extensions-cli -y
```
<br>


### 21. Install Nvidia Drivers
You can use the nvidia-smi command after install/reboot to check the drivers 
```
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo 
sudo dnf install kernel-headers-$(uname -r) kernel-devel-$(uname -r) tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglvnd-devel acpid pkgconfig dkms 
sudo dnf module install nvidia-driver:latest-dkms 
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


### 1. Install Resources (A Windows-like Task Manager)
```
flatpak install flathub net.nokyan.Resources -y
sudo flatpak override --env=GTK_THEME=Adwaita:dark net.nokyan.Resources
```
<br>



### 2. Install Remmina (Remote Desktop Client)
```
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub org.remmina.Remmina
```
<br>



### 3. Install Boxes (Simple Virtual machine software)
```
sudo flatpak install org.gnome.Boxes -y
```
<br>


### 4. Install Calendar
```
flatpak install flathub org.gnome.Calendar -y
sudo flatpak override --env=GTK_THEME=Adwaita:dark org.gnome.Calendar
```
<br>


### 5. Install Sticky Notes
```
sudo flatpak install com.vixalien.sticky -y
```
<br>


### 6. Install Paper (very simple markdown notes)
```
sudo flatpak install io.posidon.Paper -y
```
<br>



### 7. Install VSCode
```
flatpak install flathub com.visualstudio.code -y
```
<br>


### 8. Install Obsidian
```
flatpak install flathub md.obsidian.Obsidian -y
```
<br>


### 9. Install Celluloid
```
flatpak install io.github.celluloid_player.Celluloid -y
```
<br>


### 10. Install ProtonPlus (for steam)
```
flatpak install com.vysp3r.ProtonPlus -y
```
<br>


### 11. Install Steam (for games/ nvidia testing)
```
flatpak install com.valvesoftware.Steam -y
```
<br>
<br>
<br>
<br>


## DCC apps

### 1. Install Natron (why? cli automation stuff)
```
sudo flatpak install fr.natron.Natron -y
```
<br>



### 1. Install Blender
```
flatpak install flathub org.blender.Blender
```
<br>
<br>
<br>
<br>


## DE customisation 

### 1. Install Papirus Icons
#### https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
Install it in the root folder:
```
sudo wget -qO- https://git.io/papirus-icon-theme-install | sh
```
<br>


### 2. Install Papirus Folder Colors
#### https://github.com/PapirusDevelopmentTeam/papirus-folders
Install it in the root folder:
```
sudo wget -qO- https://git.io/papirus-folders-install | sh
```
Switch folder color to black:
```
papirus-folders -C grey --theme Papirus-Dark
```
<br>


### 3. Install custom Adwaita-dark themes
Download the themes zip:
#### https://github.com/DangerDrome/DangerOS/blob/main/themes.tar.xz
Extract and copy the folder to the themes directory:
```
cd /usr/share/themes
sudo cp -r /home/danger/Downloads/Adwaita-gray-dark 
```
