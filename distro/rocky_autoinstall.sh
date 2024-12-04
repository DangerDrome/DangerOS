# Auto Install Script (WIP)
```
#!/bin/bash
cat << EOF

░█▀▄░█▀█░█▀█░█▀▀░█▀▀░█▀▄░█▀█░█▀▀
░█░█░█▀█░█░█░█░█░█▀▀░█▀▄░█░█░▀▀█
░▀▀░░▀░▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀
Auto Install.

EOF
# Bash script Aliases
# DangerOS Auto Install
# Rocky Linux 9.5 version

#############################
# Variables
#############################

CWD=$(pwd)
SLEEP=0
USERS=$(awk -F: '$3 > 999 && $3 < 65534 {print $1}' /etc/passwd | sort)
FUSION="https://download1.rpmfusion.org"
GNOME=$(grep -E -v '(^\#)|(^\s+$)' ${CWD}/pkglists/gnome.txt)
PAKS=$(grep -E -v '(^\#)|(^\s+$)' ${CWD}/pkglists/paks.txt)


#############################
# Update System:
#############################

dnf update -y


#############################
# Install Repos
#############################

sudo dnf install epel-release -y


#############################
# Enable ssh:
#############################

systemctl start sshd
systemctl enable sshd
systemctl status sshd
hostname -I


#############################
# Install el9 packages:
#############################

sudo dnf install -y \
--setopt=install_weak_deps=False \
xrdp \
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


#############################
# Install flatpak packages:
#############################

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


#############################
# Enable XRDP:
#############################

sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo firewall-cmd --permanent --add-port=3389/tcp
sudo firewall-cmd --reload


#############################
# Make stuff Dark:
#############################

gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

```

