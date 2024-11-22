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

## Speed up dnf installs
```
sudo nano /etc/dnf/dnf.conf

# Add the following lines:
max_parallel_downloads=10
fastestmirror=True
```


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


## Install gnome extension CLI
```
sudo pip install --upgrade git+https://github.com/essembeh/gnome-extensions-cli -y
```


## Install Gnome Extension Manager
```
flatpak install flathub com.mattjakeman.ExtensionManager -y
```


## Install Remmina (Remote Desktop Client)
```
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub org.remmina.Remmina

```


## Install Blender
```
flatpak install flathub org.blender.Blender
```


## Install fonts for everyone

```
cd /usr/share/fonts
sudo mkdir meslo-lgs-nf
cd meslo-lgs-nf
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/MesloLGS%20NF%20Regular.ttf --output 'MesloLGS-NF-Regular.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/MesloLGS%20NF%20Bold.ttf --output 'MesloLGS-NF-Bold.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/MesloLGS%20NF%20Italic.ttf --output 'MesloLGS-NF-Italic.ttf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/MesloLGS%20NF%20Bold%20Italic.ttf --output 'MesloLGS-NF-Bold-Italic.ttf'
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
