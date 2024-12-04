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

  echo "Checking for EPEL repository..."
  if ! rpm -q epel-release >/dev/null; then
    sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
  fi
}

setup_repositories() {
  echo "Setting up repositories..."
  rm -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/*.rpmsave
  cp -f ${CWD}/dnf/rocky.repo /etc/yum.repos.d/
  sudo dnf install -y epel-release
  sudo dnf install -y ${FUSION}/free/el/rpmfusion-free-release-9.noarch.rpm
  sudo dnf install -y ${FUSION}/nonfree/el/rpmfusion-nonfree-release-9.noarch.rpm
}

install_packages() {
  echo "Installing base packages..."
  for PACKAGE in ${BASE}; do
    sudo dnf install -y ${PACKAGE}
  done
}

remove_packages() {
  echo "Removing base packages..."
  for PACKAGE in ${BASE}; do
    sudo dnf remove -y ${PACKAGE}
  done
}

install_gnome_extensions() {
  echo "Installing GNOME extensions..."
  for EXT in ${GNOME}; do
    sudo gnome-extensions install --force ${EXT}
    sudo gnome-extensions enable ${EXT}
  done
}

remove_gnome_extensions() {
  echo "Removing GNOME extensions..."
  for EXT in ${GNOME}; do
    sudo gnome-extensions disable ${EXT}
    sudo gnome-extensions uninstall ${EXT}
  done
}

install_flatpak_apps() {
  echo "Installing Flatpak apps..."
  for APP in ${FLATPAK}; do
    flatpak install -y ${APP}
  done
}

remove_flatpak_apps() {
  echo "Removing Flatpak apps..."
  for APP in ${FLATPAK}; do
    flatpak uninstall -y ${APP}
  done
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
  cp -f ${CWD}/bash/bashrc /root/.bashrc
  cp -f ${CWD}/bash/bash_aliases /root/.bash_aliases
  for USER in ${USERS}; do
    if [[ -d /home/${USER} ]]; then
      cp -f ${CWD}/bash/bashrc /home/${USER}/.bashrc
      cp -f ${CWD}/bash/bash_aliases /home/${USER}/.bash_aliases
      chown ${USER}:${USER} /home/${USER}/.bashrc /home/${USER}/.bash_aliases
    fi
  done
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

enable_dark_mode() {
  echo "Enabling dark mode for GNOME desktop and applications globally..."

  # Ensure dconf CLI is installed
  if ! command -v dconf &>/dev/null; then
    echo "Installing dconf to configure system-wide GNOME settings..."
    sudo dnf install -y dconf
  fi

  # Set system-wide GNOME desktop to dark mode
  echo "Setting system-wide GNOME desktop to dark mode..."
  sudo mkdir -p /etc/dconf/db/local.d
  echo "[org/gnome/desktop/interface]" | sudo tee /etc/dconf/db/local.d/00-dark-mode > /dev/null
  echo "gtk-theme='Adwaita-dark'" | sudo tee -a /etc/dconf/db/local.d/00-dark-mode > /dev/null
  echo "color-scheme='prefer-dark'" | sudo tee -a /etc/dconf/db/local.d/00-dark-mode > /dev/null

  # Ensure GNOME Tweaks compatibility (User Themes)
  echo "[org/gnome/shell/extensions/user-theme]" | sudo tee -a /etc/dconf/db/local.d/00-dark-mode > /dev/null
  echo "name='Adwaita-dark'" | sudo tee -a /etc/dconf/db/local.d/00-dark-mode > /dev/null

  # Apply the settings
  echo "Applying system-wide GNOME dark mode settings..."
  sudo dconf update

  # Adjust Flatpak applications to use dark mode
  echo "Applying dark mode to Flatpak applications globally..."
  flatpak override --env=GTK_THEME=Adwaita:dark org.gnome.Calendar
  flatpak override --env=GTK_THEME=Adwaita:dark org.mozilla.firefox
  flatpak override --env=GTK_THEME=Adwaita:dark com.spotify.Client

  echo "Dark mode has been applied globally. Please restart the system or GNOME Shell to see changes."
}

increase_scaling_factor() {
  echo "Setting GNOME text scaling factor to 1.5 globally..."

  # Ensure dconf CLI is installed
  if ! command -v dconf &>/dev/null; then
    echo "Installing dconf to configure system-wide GNOME settings..."
    sudo dnf install -y dconf
  fi

  # Set system-wide GNOME scaling factor
  echo "Configuring system-wide GNOME text scaling factor..."
  sudo mkdir -p /etc/dconf/db/local.d
  echo "[org/gnome/desktop/interface]" | sudo tee /etc/dconf/db/local.d/01-scaling-factor > /dev/null
  echo "text-scaling-factor=1.5" | sudo tee -a /etc/dconf/db/local.d/01-scaling-factor > /dev/null

  # Apply the settings
  echo "Applying system-wide GNOME scaling factor..."
  sudo dconf update

  echo "GNOME text scaling factor has been set to 1.5 globally. Please restart GNOME Shell or the system to apply changes."
}

#############################
# User Menu
#############################

run_tasks() {
  local tasks=(
    "1" "Set up repositories" off
    "2" "Install base packages" off
    "3" "Remove installed packages" off
    "4" "Install GNOME extensions" off
    "5" "Remove GNOME extensions" off
    "6" "Install Flatpak apps" off
    "7" "Remove Flatpak apps" off
    "8" "Configure system (SSH/XRDP)" off
    "9" "Remove system configuration (SSH/XRDP)" off
    "10" "Install Docker" off
    "11" "Remove Docker" off
    "12" "Customize environment" off
    "13" "Remove customizations" off
    "14" "Mount network locations" off
    "15" "Remove network mounts" off
    "16" "Enable dark mode globally" off
    "17" "Increase GNOME scaling factor to 1.5" off
  )
  local choices=$(dialog --separate-output --checklist "Select tasks to perform:" 20 50 17 "${tasks[@]}" 3>&1 1>&2 2>&3)
  clear

  check_prerequisites

  for choice in $choices; do
    case $choice in
      1) setup_repositories ;;
      2) install_packages ;;
      3) remove_packages ;;
      4) install_gnome_extensions ;;
      5) remove_gnome_extensions ;;
      6) install_flatpak_apps ;;
      7) remove_flatpak_apps ;;
      8) configure_system ;;
      9) remove_system_configuration ;;
      10) install_docker ;;
      11) remove_docker ;;
      12) customize_environment ;;
      13) remove_customizations ;;
      14) auto_mount_network_locations ;;
      15) remove_mounts ;;
      16) enable_dark_mode ;;
      17) increase_scaling_factor ;;
      *) echo "Invalid option: ${choice}" ;;
    esac
  done
}

install_dialog
run_tasks
echo "All selected tasks completed. Reboot is recommended."
