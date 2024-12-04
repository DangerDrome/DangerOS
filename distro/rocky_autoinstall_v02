#!/bin/bash

# rocky_autoinstall.sh
# Modular Auto Install Script for Rocky Linux 9.x

#############################
# Variables
#############################

CWD=$(pwd)
USERS=$(awk -F: '$3 > 999 && $3 < 65534 {print $1}' /etc/passwd | sort)
FUSION="https://download1.rpmfusion.org"
BASE=$(grep -E -v '(^\#)|(^\s+$)' ${CWD}/pkgs/base.txt)
FLATPAK=$(grep -E -v '(^\#)|(^\s+$)' ${CWD}/pkgs/flatpak.txt)
GNOME=$(grep -E -v '(^\#)|(^\s+$)' ${CWD}/pkgs/gnome.txt)
REMOVE=$(grep -E -v '(^\#)|(^\s+$)' ${CWD}/pkgs/remove.txt)
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

  source /etc/os-release
  if [[ "${ROCKY_SUPPORT_PRODUCT}" != "Rocky-Linux-9" || "${ROCKY_SUPPORT_PRODUCT_VERSION}" < "9" ]]; then
    echo "Unsupported OS version. This script is only for Rocky Linux 9.x." >&2
    exit 1
  fi
}

setup_repositories() {
  echo "Setting up repositories..."
  rm -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/*.rpmsave
  cp -f ${CWD}/dnf/rocky.repo /etc/yum.repos.d/
  for REPO in baseos appstream crb extras; do
    dnf config-manager --set-enabled ${REPO}
  done
  dnf install -y epel-release
}

install_packages() {
  echo "Installing base packages..."
  dnf install -y ${BASE}
  dnf install -y flatpak
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

remove_packages() {
  echo "Removing base packages..."
  dnf remove -y ${BASE}
}

remove_repositories() {
  echo "Removing repositories..."
  dnf remove -y epel-release rpmfusion-free-release rpmfusion-nonfree-release
}

remove_flatpak_apps() {
  echo "Removing Flatpak apps..."
  for PACKAGE in ${FLATPAK}; do
    flatpak uninstall -y ${PACKAGE}
  done
}

remove_docker() {
  echo "Removing Docker..."
  systemctl stop docker
  dnf remove -y docker-ce docker-ce-cli containerd.io
}

remove_nvidia_drivers() {
  echo "Removing NVIDIA drivers..."
  dnf remove -y nvidia-driver kernel-devel kernel-headers
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
    "3" "Remove unnecessary packages" off
    "4" "Configure system" off
    "5" "Install Docker" off
    "6" "Customize environment" off
    "7" "Install NVIDIA drivers" off
    "8" "Install custom fonts" off
    "9" "Mount network locations" off
    "10" "Remove repositories" off
    "11" "Remove installed packages" off
    "12" "Remove Flatpak apps" off
    "13" "Remove Docker" off
    "14" "Remove NVIDIA drivers" off
    "15" "Remove customizations" off
    "16" "Remove network mounts" off
    "17" "Perform all tasks" off
  )
  local choices=$(dialog --separate-output --checklist "Select tasks to perform:" 20 50 10 "${tasks[@]}" 3>&1 1>&2 2>&3)
  clear

  check_prerequisites

  for choice in $choices; do
    case $choice in
      1) setup_repositories ;;
      2) install_packages ;;
      3) remove_unnecessary_packages ;;
      4) configure_system ;;
      5) install_docker ;;
      6) customize_environment ;;
      7) install_nvidia_drivers ;;
      8) install_fonts ;;
      9) auto_mount_network_locations ;;
      10) remove_repositories ;;
      11) remove_packages ;;
      12) remove_flatpak_apps ;;
      13) remove_docker ;;
      14) remove_nvidia_drivers ;;
      15) remove_customizations ;;
      16) remove_mounts ;;
      17)
        setup_repositories
        install_packages
        remove_unnecessary_packages
        configure_system
        install_docker
        customize_environment
        install_nvidia_drivers
        install_fonts
        auto_mount_network_locations
        ;;
      *) echo "Invalid option: ${choice}" ;;
    esac
  done
}

install_dialog
run_tasks
echo "All selected tasks completed. Reboot is recommended."
