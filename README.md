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
### playbook:
```
comming soon...
```
> [!TIP]
> Lean more about ansible here: https://www.ansible.com/how-ansible-works/


# Bash install
### Run the folloing in a shell:
```
comming soon...
```
> [!WARNING]
> Use bash scripts at your own risk, read the code carefully before executing.


# Step by step install
## 1. Download rocky linux
https://rockylinux.org/download | 
https://dl.rockylinux.org/pub/rocky/9/live/x86_64/Rocky-9-Workstation-x86_64-latest.iso


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
