#!/bin/bash
#
# rocky_autoinstall.sh
# DangerOS Auto Install
# Rocky Linux 9.x


#############################
# Variables
#############################

CWD=$(pwd)
SLEEP=1
USERS=$(awk -F: '$3 > 999 && $3 < 65534 {print $1}' /etc/passwd | sort)

FUSION="https://download1.rpmfusion.org"

BASE=$(grep -E -v '(^\#)|(^\s+$)' ${CWD}/pkgs/base.txt)
FLATPAK=$(grep -E -v '(^\#)|(^\s+$)' ${CWD}/pkgs/flatpak.txt)
GNOME=$(grep -E -v '(^\#)|(^\s+$)' ${CWD}/pkgs/gnome.txt)
REMOVE=$(grep -E -v '(^\#)|(^\s+$)' ${CWD}/pkgs/remove.txt)


#############################
# Init
#############################

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
  echo
  echo "  Please run with sudo or as root." >&2
  echo
  exit 1
fi

# Make sure we're running Rocky Linux 9.x.
if [ -f /etc/os-release ]
then
  source /etc/os-release
  SYSTEM="${ROCKY_SUPPORT_PRODUCT}"
  VERSION="${ROCKY_SUPPORT_PRODUCT_VERSION}"
fi
if [ "${SYSTEM}" != "Rocky Linux" ] && [ "${VERSION}" != "9" ] 
then
  echo
  echo "Unsupported operating system." >&2
  echo
  exit 1
fi

sleep ${SLEEP}
cat << EOF

░█▀▄░█▀█░█▀█░█▀▀░█▀▀░█▀▄░█▀█░█▀▀
░█░█░█▀█░█░█░█░█░█▀▀░█▀▄░█░█░▀▀█
░▀▀░░▀░▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀
[>] Auto Install.

EOF
sleep ${SLEEP}


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

# echo "[>] Removing existing repositories"
# rm -f /etc/yum.repos.d/*.repo
# rm -f /etc/yum.repos.d/*.rpmsave
# sleep ${SLEEP}

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

echo "[>] INstalling & Enabling repository: Flathub"
dnf install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sleep ${SLEEP}


#############################
# Install base packages:
#############################

echo "[>] Installing some additional packages."
sleep ${SLEEP}
for PACKAGE in ${BASE}
do
  if ! rpm -q ${PACKAGE} > /dev/null 2>&1
  then
    echo "[>] Installing package: ${PACKAGE}"
    dnf install -y ${PACKAGE} > /dev/null
    sleep ${SLEEP}
  fi
done
echo "[>] Basic packages have been installed on the system."
sleep ${SLEEP}


#######################
# Install flatpak apps:
#######################

echo "[>] Installing flatpak apps"
sleep ${SLEEP}
for PACKAGE in ${FLATPAK}
do
  if ! rpm -q ${PACKAGE} > /dev/null 2>&1
  then
    echo "[>] Installing package: ${PACKAGE}"
    flatpak install -y ${PACKAGE} > /dev/null
    sleep ${SLEEP}
  fi
done
echo "[>] Flatpak apps have been installed on the system."
sleep ${SLEEP}


##################################
# Install gnome & enable packages:
##################################

echo "[>] Installing gnome specific packages."
sleep ${SLEEP}
for PACKAGE in ${GNOME}
do
  if ! rpm -q ${PACKAGE} > /dev/null 2>&1
  then
    echo "[>] Installing package: ${PACKAGE}"
    gnome-extensions install -y ${PACKAGE} > /dev/null
    sleep ${SLEEP}
  fi
done
echo "[>] Gnome specific packages have been installed."
sleep ${SLEEP}

echo "[>] Enabling gnome specific packages"
sleep ${SLEEP}
for PACKAGE in ${GNOME}
do
  if ! rpm -q ${PACKAGE} > /dev/null 2>&1
  then
    echo "[>] Installing package: ${PACKAGE}"
    gnome-extensions enable ${PACKAGE} > /dev/null
    sleep ${SLEEP}
  fi
done
echo "[>] Gnome specific packages have been enabled."
sleep ${SLEEP}


##########################
# Remove useless packages:
##########################

echo "[>] Removing useless packages"
sleep ${SLEEP}
dnf remove -y ${REMOVE} > /dev/null
echo "[>] Useless packages have been removed from the system."
sleep ${SLEEP}


#################
# Install Docker:
#################

echo "[>] Installing docker"
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io -y
sudo systemctl enable --now docker
echo "[>] Docker installed"

echo "[>] Installing dockge"
sudo mkdir -p /opt/stacks /opt/dockge
cd /opt/dockge
sudo curl https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml --output compose.yaml
sudo docker compose up -d
echo "[>] Dockge installed: https://127.0.0.1:5001"


##############
# Enable XRDP:
##############

sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo firewall-cmd --permanent --add-port=3389/tcp
sudo firewall-cmd --reload


##################
# Customisations:
##################

gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
echo "[>] Dark mode activated."

echo "[>] Installing terminal fonts."
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

echo "[>] Installing default terminal profile."
cd ~/
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/terminal/gnome-terminal-profiles.dconf --output 'gnome-terminal-profiles.dconf'
sudo curl -L https://github.com/DangerDrome/DangerOS/raw/main/terminal/logo_02.txt --output 'logo_02.txt'
exec bash

source ~/.bashrc
load
r
c
ff
echo "[>] Bash Terminal customized."


#########################
# Install nvidia drivers:
#########################

echo "[>] Installing NVIDIA drivers on the system."
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo 
sudo dnf install kernel-headers-$(uname -r) kernel-devel-$(uname -r) tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglvnd-devel acpid pkgconfig dkms -y
sudo dnf module install nvidia-driver:latest-dkms -y
echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf 
echo 'omit_drivers+=" nouveau "' | sudo tee /etc/dracut.conf.d/blacklist-nouveau.conf 
sudo dracut --regenerate-all --force 
sudo depmod -a
echo "[>] NVIDIA drivers have been installed."


#########################
# Finish:
#########################

sudo dnf clean
echo "[>] Time to reboot!."
