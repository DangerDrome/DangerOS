# Auto Install Script (WIP)
```
#!/bin/bash
cat << EOF

░█▀▄░█▀█░█▀█░█▀▀░█▀▀░█▀▄░█▀█░█▀▀
░█░█░█▀█░█░█░█░█░█▀▀░█▀▄░█░█░▀▀█
░▀▀░░▀░▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀
[>] Auto Install.

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
# Setup bash & aliases:
#############################

echo "[>] Installing .bashrc & bash_aliases for user: root"
cp -f ${CWD}/bash/bashrc /root/.bashrc
cp -f ${CWD}/bash/bash_aliases /root/.bash_aliases
sleep ${SLEEP}

if [ ! -z "${USERS}" ]
then
  for USER in ${USERS}
  do
    if [ -d /home/${USER} ]
    then
      echo "[>] Installing .bashrc & bash_aliases for user: ${USER}"
      cp -f ${CWD}/bash/bashrc /home/${USER}/.bashrc
      cp -f ${CWD}/bash/bash_aliases /home/${USER}/.bash_aliases
      chown ${USER}:${USER} /home/${USER}/.bashrc
      chown ${USER}:${USER} /home/${USER}/.bash_aliases
      sleep ${SLEEP}
    fi
  done
fi

echo "[>] Installing custom .bashrc for future users"
cp -f ${CWD}/bash/bashrc /etc/skel/.bashrc
cp -f ${CWD}/bash/bash_aliases /etc/skel/.bash_aliases
sleep ${SLEEP}


#############################
# Setup system basics:
#############################

echo "[>] Configuring SSH server"
sed -i -e '/AcceptEnv/s/^#\?/#/' /etc/ssh/sshd_config
systemctl reload sshd
sleep ${SLEEP}

echo "[>] Configuring persistent password for sudo"
cp -f ${CWD}/sudoers.d/persistent_password /etc/sudoers.d/
sleep ${SLEEP}


#############################
# Install repositories:
#############################

echo "[>] Removing existing repositories"
rm -f /etc/yum.repos.d/*.repo
rm -f /etc/yum.repos.d/*.rpmsave
sleep ${SLEEP}

for REPOSITORY in BaseOS AppStream Extras PowerTools
do
  echo "[>] Enabling repository: ${REPOSITORY}"
  cp -f ${CWD}/dnf/Rocky-${REPOSITORY}.repo /etc/yum.repos.d/
  sleep ${SLEEP}
done

echo "[>] Enabling repository: EPEL"
if ! rpm -q epel-release > /dev/null 2>&1
then
  dnf install -y epel-release > /dev/null
fi
cp -f ${CWD}/dnf/epel.repo /etc/yum.repos.d/
sleep ${SLEEP}

echo "[>] Enabling repository: EPEL Modular"
cp -f ${CWD}/dnf/epel-modular.repo /etc/yum.repos.d/
sleep ${SLEEP}

echo "[>] Removing repository: EPEL Testing"
rm -f /etc/yum.repos.d/epel-testing.repo
sleep ${SLEEP}

echo "[>] Removing repository: EPEL Testing Modular"
rm -f /etc/yum.repos.d/epel-testing-modular.repo
sleep ${SLEEP}

echo "[>] Enabling repository: ELRepo"
if ! rpm -q elrepo-release > /dev/null 2>&1
then
  dnf install -y elrepo-release > /dev/null
fi
cp -f ${CWD}/dnf/elrepo.repo /etc/yum.repos.d/
sleep ${SLEEP}

echo "[>] Enabling repository: RPM Fusion"
if ! rpm -q rpmfusion-free-release > /dev/null 2>&1
then
  dnf install -y rpmfusion-free-release > /dev/null
fi
cp -f ${CWD}/dnf/rpmfusion-free-updates.repo /etc/yum.repos.d/
sleep ${SLEEP}

echo "[>] Enabling repository: RPM Fusion Tainted"
if ! rpm -q rpmfusion-free-release-tainted > /dev/null 2>&1
then
  dnf install -y rpmfusion-free-release-tainted > /dev/null
fi
cp -f ${CWD}/dnf/rpmfusion-free-tainted.repo /etc/yum.repos.d/
sleep ${SLEEP}

echo "[>] Enabling repository: RPM Fusion Nonfree"
if ! rpm -q rpmfusion-nonfree-release > /dev/null 2>&1
then
  dnf install -y ${FUSION}/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm  > /dev/null
fi
cp -f ${CWD}/dnf/rpmfusion-nonfree-updates.repo /etc/yum.repos.d/
sleep ${SLEEP}



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


#############################
# Install gnome extentions:
#############################

gnome-extensions install -y \
clipboard-indicator@Dieg0Js.github.io \
gnome-shell-screenshot@ttll.de \
ding@rastersoft.com \
add-to-desktop@tommimon.github.com \
hide-universal-access@akiirui.github.io \
appindicatorsupport@rgcjonas.gmail.com \
dash-to-panel@gnome-shell-extensions.gcampax.github.com \
workspace-indicator@gnome-shell-extensions.gcampax.github.com 

gnome-extensions enable \
gnome-extensions install -y \
clipboard-indicator@Dieg0Js.github.io \
gnome-shell-screenshot@ttll.de \
ding@rastersoft.com \
add-to-desktop@tommimon.github.com \
hide-universal-access@akiirui.github.io \
appindicatorsupport@rgcjonas.gmail.com \
dash-to-panel@gnome-shell-extensions.gcampax.github.com \
workspace-indicator@gnome-shell-extensions.gcampax.github.com 

```

