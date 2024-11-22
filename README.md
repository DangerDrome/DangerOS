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
#### DangerOS [Dangerous] is a streamlined Operating System setup for Visual Effects.
Visual effects is a pain in the ass, let's make is easier!


## Index
- [ ] Overview
- [ ] Ansible install
- [ ] Bash script install
- [x] Step by step install






# Ansible install
### Playbook:
```
comming soon...
```
> [!TIP]
> Lean more about ansible here: https://www.ansible.com/how-ansible-works/







# Bash install
### Run the following in a shell:
```
comming soon...
```
> [!WARNING]
> Use bash scripts at your own risk, read the code carefully before executing.
> We trust you have received the usual lecture from the local System
> Administrator. It usually boils down to these three things:
>
> - Respect the privacy of others.
> - Think before you type.
> - With great power comes great responsibility.







# Step by step install
## 1. Download rocky linux
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
> The renaming instructions are mostly done via the gnome terminal.



## install Nano
```
sudo dnf install nano -y
```


## install tcsh
```
sudo dnf install tcsh -y
```


## install timeshift (backups)
```
sudo dnf install timeshift -y
```


## Install mono icon fonts for the terminal 

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


## Download terminal color scheme
Get it from the DangerOS/themes folder:
- gnome-terminal-profiles.dconf



## Speed up dnf installs
```
sudo nano /etc/dnf/dnf.conf

# Add the following lines:
max_parallel_downloads=10
fastestmirror=True
```


## Disable SELinux
```
sudo nano /etc/selinux/config 
```
Add this line:
- SELINUX=disabled



## install epel repo
```
sudo dnf install epel-release -y
```

## install aditional rpms (rpmfusion,mesa)
```
cd ~/Downloads
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/rpm/mesa-libGLU-9.0.1-6.el9.x86_64.rpm --output 'mesa-libGLU-9.0.1-6.el9.x86_64.rpm'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/rpm/rpmfusion-free-release-9.noarch.rpm --output 'rpmfusion-free-release-9.noarch.rpm'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/rpm/rpmfusion-nonfree-release-9.noarch.rpm --output 'rpmfusion-nonfree-release-9.noarch.rpm'
```

## install flatpak repo
```
sudo dnf install flatpak -y
```
```
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

## Install xrdp
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


## Install tailscale
```
curl -fsSL https://tailscale.com/install.sh | sh
```

## Install KTailctl a tailscale GUI
```
flatpak install org.fkoehler.KTailctl -y
```


## Install ntfs stuff
```
sudo dnf install ntfs-3g -y
```


## Install pip
```
sudo dnf install python3-pip -y
```


## Install gnome-tweaks
```
sudo dnf install gnome-tweaks -y
```


## Install gnome-extensions
```
sudo dnf install gnome-extensions-app-40.0-3.el9.x86_64 -y
```


## Install Gnome Extension Manager
```
flatpak install flathub com.mattjakeman.ExtensionManager -y
```


## Install gnome extension CLI
```
sudo pip install --upgrade git+https://github.com/essembeh/gnome-extensions-cli -y
```

## Install Nvidia Drivers
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



> [!TIP]
> You can search for flatpak apps via the command line: 
> ```
> flatpak search <app-name>
> ```

## Install Remmina (Remote Desktop Client)
```
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub org.remmina.Remmina
```


## Install Resource (A Windows-like Task Manager)
```
flatpak install flathub net.nokyan.Resources -y
```


## Install VSCode
```
flatpak install flathub com.visualstudio.code -y
```


## Install Obsidian
```
flatpak install flathub md.obsidian.Obsidian -y
```


## Install Celluloid
```
flatpak install io.github.celluloid_player.Celluloid -y
```


## Install ProtonPlus (for steam)
```
flatpak install com.vysp3r.ProtonPlus -y
```


## Install Steam (for games)
```
flatpak install com.valvesoftware.Steam -y
```


## Install Blender
```
flatpak install flathub org.blender.Blender
```


## Install Papirus Icons
#### https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
Install it in the root folder:
```
sudo wget -qO- https://git.io/papirus-icon-theme-install | sh
```

## Install Papirus Folder Colors
#### https://github.com/PapirusDevelopmentTeam/papirus-folders
Install it in the root folder:
```
sudo wget -qO- https://git.io/papirus-folders-install | sh
```
Switch folder color to black:
```
papirus-folders -C grey --theme Papirus-Dark
```
## Install custom Adwaita-dark themes
Download the themes zip:
#### https://github.com/DangerDrome/DangerOS/blob/main/themes.tar.xz
Extract and copy the folder to the themes directory:
```
cd /usr/share/themes
sudo cp -r /home/danger/Downloads/Adwaita-gray-dark 
```
