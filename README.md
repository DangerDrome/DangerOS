# DangerOS
Installation instructions for DangerOS
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
## Install Fonts for everyone

```
sudo su
cd /usr/share/fonts
mkdir meslo-lgs-nf
cd meslo-lgs-nf
curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/MesloLGS%20NF%20Regular.ttf --output 'MesloLGS-NF-Regular.ttf'
curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/MesloLGS%20NF%20Bold.ttf --output 'MesloLGS-NF-Bold.ttf'
curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/MesloLGS%20NF%20Italic.ttf --output 'MesloLGS-NF-Italic.ttf'
curl -L https://github.com/DangerDrome/DangerOS/raw/main/fonts/MesloLGS%20NF%20Bold%20Italic.ttf --output 'MesloLGS-NF-Bold-Italic.ttf'
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
