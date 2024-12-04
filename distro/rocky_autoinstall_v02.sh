#!/bin/bash

# rocky_autoinstall.sh
# Modular Auto Install Script for Rocky Linux 9.x

#############################
# Variables
#############################

CWD=$(pwd)
USERS=$(awk -F: '$3 > 999 && $3 < 65534 {print $1}' /etc/passwd | sort)
BASE="firefox flatpak xdg-desktop-portal-gnome"
EXTRA_PACKAGES="vlc keepassxc ImageMagick timeshift ffmpeg fastfetch gthumb mediainfo tldr htop ntfs-3g unrar xrdp"
FLATPAK="org.gimp.GIMP org.videolan.VLC"
REMOVE="nano"
NETWORK_CONFIG="${CWD}/network/locations.txt"

#############################
# Functions
#############################

install_dialog() {
  if ! command -v dialog &>/dev/null; then
    echo "Installing dialog for interactive menu..."
    sudo dnf install dialog -y
  fi
}

check_prerequisites() {
  if [[ "${UID}" -ne 0 ]]; then
    echo "Please run this script as root or with sudo." >&2
    exit 1
  fi

  echo "Checking for EPEL repository..."
  if ! rpm -q epel-release >/dev/null; then
    sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
  fi
}

setup_repositories() {
  echo "Setting up repositories..."
  sudo dnf install -y epel-release
  sudo dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm
  sudo dnf install -y https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-9.noarch.rpm
}

install_packages() {
  echo "Installing base packages..."
  sudo dnf install -y ${BASE} ${EXTRA_PACKAGES}
}

remove_packages() {
  echo "Removing base packages..."
  sudo dnf remove -y ${BASE} ${EXTRA_PACKAGES}
}

remove_flatpak_apps() {
  echo "Removing Flatpak apps..."
  for PACKAGE in ${FLATPAK}; do
    flatpak uninstall -y ${PACKAGE}
  done
}

remove_repositories() {
  echo "Removing repositories..."
  sudo dnf remove -y epel-release rpmfusion-free-release rpmfusion-nonfree-release
}

configure_system() {
  echo "Configuring SSH and XRDP..."
  sudo systemctl enable --now sshd
  sudo systemctl enable --now xrdp
  sudo firewall-cmd --permanent --add-port=3389/tcp
  sudo firewall-cmd --reload
}

remove_system_configuration() {
  echo "Removing SSH and XRDP configuration..."
  sudo systemctl disable --now sshd
  sudo systemctl disable --now xrdp
  sudo firewall-cmd --remove-port=3389/tcp --permanent
  sudo firewall-cmd --reload
}

install_docker() {
  echo "Installing Docker..."
  sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl enable --now docker
}

remove_docker() {
  echo "Removing Docker..."
  sudo systemctl disable --now docker
  sudo dnf remove -y docker-ce docker-ce-cli containerd.io
}

customize_environment() {
  echo "Customizing bash environment..."
  for USER in ${USERS}; do
    if [[ -d /home/${USER} ]]; then
      cp -f ${CWD}/bash/bashrc /home/${USER}/.bashrc
      cp -f ${CWD}/bash/bash_aliases /home/${USER}/.bash_aliases
      chown ${USER}:${USER} /home/${USER}/.bashrc /home/${USER}/.bash_aliases
    fi
  done
  cp -f ${CWD}/bash/bashrc /root/.bashrc
  cp -f ${CWD}/bash/bash_aliases /root/.bash_aliases
}

remove_customizations() {
  echo "Removing bash customizations..."
  rm -f /root/.bashrc /root/.bash_aliases
  for USER in ${USERS}; do
    if [[ -d /home/${USER} ]]; then
      rm -f /home/${USER}/.bashrc /home/${USER}/.bash_aliases
    fi
  done
}

install_nvidia_drivers() {
  echo "Installing NVIDIA drivers..."
  sudo dnf config-manager --add-repo=https://developer.download.nvidia.com/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo
  sudo dnf install -y kernel-headers kernel-devel gcc dkms nvidia-driver
}

remove_nvidia_drivers() {
  echo "Removing NVIDIA drivers..."
  sudo dnf remove -y nvidia-driver kernel-devel kernel-headers
}

auto_mount_network_locations() {
  echo "Mounting SMB network locations..."
  while IFS=, read -r SHARE MOUNT_POINT OPTIONS; do
    if [[ ! -d "${MOUNT_POINT}" ]]; then
      mkdir -p "${MOUNT_POINT}"
    fi
    mount -t cifs -o "${OPTIONS}" "//${SHARE}" "${MOUNT_POINT}"
  done < "${NETWORK_CONFIG}"
}

remove_mounts() {
  echo "Removing network mounts..."
  while IFS=, read -r _ MOUNT_POINT _; do
    if mount | grep -qs "${MOUNT_POINT}"; then
      umount -l "${MOUNT_POINT}"
      rm -rf "${MOUNT_POINT}"
    fi
  done < "${NETWORK_CONFIG}"
  sed -i '/cifs/d' /etc/fstab
}

#############################
# User Menu
#############################

run_tasks() {
  local tasks=(
    "1" "Set up repositories" off
    "2" "Install packages" off
    "3" "Remove installed packages" off
    "4" "Configure system" off
    "5" "Remove system configuration" off
    "6" "Install Docker" off
    "7" "Remove Docker" off
    "8" "Customize environment" off
    "9" "Remove customizations" off
    "10" "Install NVIDIA drivers" off
    "11" "Remove NVIDIA drivers" off
    "12" "Mount network locations" off
    "13" "Remove network mounts" off
    "14" "Remove repositories" off
    "15" "Remove Flatpak apps" off
  )
  local choices=$(dialog --separate-output --checklist "Select tasks to perform:" 20 50 15 "${tasks[@]}" 3>&1 1>&2 2>&3)
  clear

  check_prerequisites

  for choice in $choices; do
    case $choice in
      1) setup_repositories ;;
      2) install_packages ;;
      3) remove_packages ;;
      4) configure_system ;;
      5) remove_system_configuration ;;
      6) install_docker ;;
      7) remove_docker ;;
      8) customize_environment ;;
      9) remove_customizations ;;
      10) install_nvidia_drivers ;;
      11) remove_nvidia_drivers ;;
      12) auto_mount_network_locations ;;
      13) remove_mounts ;;
      14) remove_repositories ;;
      15) remove_flatpak_apps ;;
      *) echo "Invalid option: ${choice}" ;;
    esac
  done
}

install_dialog
run_tasks
echo "All selected tasks completed. Reboot is recommended."
