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

  # Remove old repository files
  echo "Removing old repository files..."
  sudo rm -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/*.rpmsave

  # Add Rocky repositories
  echo "Adding Rocky Linux repositories..."
  sudo cp -f "${CWD}/dnf/rocky.repo" /etc/yum.repos.d/
  sudo dnf install -y epel-release

  # Add RPM Fusion repositories
  echo "Adding RPM Fusion repositories..."
  sudo dnf install -y "${FUSION}/free/el/rpmfusion-free-release-9.noarch.rpm"
  sudo dnf install -y "${FUSION}/nonfree/el/rpmfusion-nonfree-release-9.noarch.rpm"

  # Install Flatpak and configure Flathub
  echo "Installing Flatpak..."
  sudo dnf install -y flatpak
  echo "Adding Flathub repository..."
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # Notify user
  echo "Repositories have been set up, including Flatpak and Flathub."
}

install_packages() {
  echo "Installing base packages..."
  for PACKAGE in ${BASE}; do
    sudo dnf install -y ${PACKAGE}
  done
}

install_gnome_extensions() {
  echo "Installing GNOME extensions..."
  for EXT in ${GNOME}; do
    sudo gnome-extensions install --force ${EXT}
    sudo gnome-extensions enable ${EXT}
  done
}

install_flatpak_apps() {
  echo "Installing Flatpak apps..."
  for APP in ${FLATPAK}; do
    flatpak install -y ${APP}
  done
}

configure_system() {
  echo "Configuring SSH and XRDP..."
  sudo systemctl enable --now sshd
  sudo systemctl enable --now xrdp
  sudo firewall-cmd --permanent --add-port=3389/tcp
  sudo firewall-cmd --reload
}

install_docker() {
  echo "Installing Docker..."
  sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl enable --now docker
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

auto_mount_network_locations() {
  echo "Mounting SMB network locations..."
  while IFS=, read -r SHARE MOUNT_POINT OPTIONS; do
    if [[ ! -d "${MOUNT_POINT}" ]]; then
      mkdir -p "${MOUNT_POINT}"
    fi
    mount -t cifs -o "${OPTIONS}" "//${SHARE}" "${MOUNT_POINT}"
  done < "${NETWORK_CONFIG}"
}

white_label_os() {
  echo "Applying white-label branding to Rocky Linux..."

  # Define the branding directory
  BRANDING_DIR="${CWD}/media/brand"

  # Ensure the branding directory exists
  if [[ ! -d "${BRANDING_DIR}" ]]; then
    echo "Branding directory not found at ${BRANDING_DIR}. Creating it now..."
    sudo mkdir -p "${BRANDING_DIR}"
    echo "Please add the following files to ${BRANDING_DIR}:"
    echo "  - grub_background.png: Custom GRUB background."
    echo "  - gdm_background.png: Custom GNOME login screen background."
    echo "  - os-release: Custom OS branding."
    echo "  - logo.png: Custom system logo."
    echo "After adding these files, rerun this script."
    exit 1
  fi

  # Define paths for branding assets
  GRUB_BACKGROUND="/boot/grub2/themes/Rocky/background.png"
  GDM_BACKGROUND="/usr/share/gnome-shell/theme/gnome-shell-theme.gresource"
  OS_RELEASE="/etc/os-release"
  ROCKY_LOGO="/usr/share/pixmaps/rocky-logo.png"

  # Replace GRUB background
  if [[ -f "${BRANDING_DIR}/grub_background.png" ]]; then
    echo "Replacing GRUB background..."
    sudo cp "${BRANDING_DIR}/grub_background.png" "${GRUB_BACKGROUND}"
  else
    echo "Warning: grub_background.png not found in ${BRANDING_DIR}. Skipping GRUB background replacement."
  fi

  # Replace GDM background
  if [[ -f "${BRANDING_DIR}/gdm_background.png" ]]; then
    echo "Replacing GDM background..."
    sudo cp "${BRANDING_DIR}/gdm_background.png" "${GDM_BACKGROUND}"
  else
    echo "Warning: gdm_background.png not found in ${BRANDING_DIR}. Skipping GDM background replacement."
  fi

  # Update OS branding in /etc/os-release
  if [[ -f "${BRANDING_DIR}/os-release" ]]; then
    echo "Updating OS branding in /etc/os-release..."
    sudo cp "${BRANDING_DIR}/os-release" "${OS_RELEASE}"
  else
    echo "Warning: os-release not found in ${BRANDING_DIR}. Skipping OS branding update."
  fi

  # Replace Rocky logo
  if [[ -f "${BRANDING_DIR}/logo.png" ]]; then
    echo "Replacing system logo..."
    sudo cp "${BRANDING_DIR}/logo.png" "${ROCKY_LOGO}"
  else
    echo "Warning: logo.png not found in ${BRANDING_DIR}. Skipping logo replacement."
  fi

  # Notify user
  echo "White-label branding process completed."
  echo "Please restart your system for all changes to take effect."
}

set_desktop_wallpaper() {
  echo "Changing desktop wallpaper for all users..."

  # Define the path to the wallpaper in the branding directory
  BRANDING_DIR="${CWD}/media/brand"
  WALLPAPER_FILE="${BRANDING_DIR}/wallpaper.jpg"

  # Ensure the wallpaper file exists
  if [[ ! -f "${WALLPAPER_FILE}" ]]; then
    echo "Error: Wallpaper file not found at ${WALLPAPER_FILE}."
    echo "Please place a wallpaper.jpg file in ${BRANDING_DIR} and rerun this function."
    return 1
  fi

  # Set wallpaper for the current user
  echo "Setting wallpaper for the current user..."
  gsettings set org.gnome.desktop.background picture-uri "file://${WALLPAPER_FILE}"
  gsettings set org.gnome.desktop.background picture-options "zoom"

  # Set wallpaper for all existing users
  echo "Setting wallpaper for all users..."
  for USER in ${USERS}; do
    if [[ -d "/home/${USER}/.config" ]]; then
      su -c "gsettings set org.gnome.desktop.background picture-uri 'file://${WALLPAPER_FILE}'" "${USER}" 2>/dev/null || {
        echo "Failed to set wallpaper for user: ${USER}. Skipping..."
      }
    fi
  done

  # Notify the user
  echo "Desktop wallpaper has been updated. Users may need to log out and log back in to see the changes."
}

enable_dark_mode() {
  echo "Enabling dark mode for GNOME desktop and applications globally..."

  # Ensure dconf CLI is installed
  if ! command -v dconf &>/dev/null; then
    echo "Installing dconf to configure GNOME system settings..."
    sudo dnf install -y dconf
  fi

  # Set system-wide GNOME desktop to dark mode
  echo "Setting GNOME desktop interface to dark mode..."
  sudo mkdir -p /etc/dconf/db/local.d
  sudo tee /etc/dconf/db/local.d/00-dark-mode > /dev/null <<EOF
[org/gnome/desktop/interface]
gtk-theme='Adwaita-dark'
color-scheme='prefer-dark'

[org/gnome/shell/extensions/user-theme]
name='Adwaita-dark'
EOF

  # Apply changes
  echo "Updating dconf database to apply dark mode settings..."
  sudo dconf update

  # Configure Flatpak apps to use dark mode
  echo "Applying dark mode for Flatpak applications..."
  flatpak override --env=GTK_THEME=Adwaita:dark org.mozilla.firefox
  flatpak override --env=GTK_THEME=Adwaita:dark com.spotify.Client
  flatpak override --env=GTK_THEME=Adwaita:dark org.gnome.Calendar

  # Notify user
  echo "Dark mode has been enabled system-wide. Please restart GNOME Shell or reboot the system to apply changes."
}


#############################
# User Menu
#############################

run_tasks() {
  local tasks=(
    "1" "Set up repositories" off
    "2" "Install base packages" off
    "3" "Install GNOME extensions" off
    "4" "Install Flatpak apps" off
    "5" "Configure system (SSH/XRDP)" off
    "6" "Install Docker" off
    "7" "Customize environment" off
    "8" "Mount network locations" off
    "9" "Enable dark mode globally" off
    "10" "Increase GNOME scaling factor to 1.5" off
    "11" "Set 100px universal padding for Nautilus" off
    "12" "Apply white-label branding to Rocky Linux" off
    "13" "Set desktop wallpaper from branding folder" off

  )
  local choices=$(dialog --separate-output --checklist "Select tasks to perform:" 20 50 12 "${tasks[@]}" 3>&1 1>&2 2>&3)
  clear

  check_prerequisites

  for choice in $choices; do
    case $choice in
      1) setup_repositories ;;
      2) install_packages ;;
      3) install_gnome_extensions ;;
      4) install_flatpak_apps ;;
      5) configure_system ;;
      6) install_docker ;;
      7) customize_environment ;;
      8) auto_mount_network_locations ;;
      9) enable_dark_mode ;;
      10) increase_scaling_factor ;;
      11) set_nautilus_padding ;;
      12) white_label_os ;;
      13) set_desktop_wallpaper ;;
      *) echo "Invalid option: ${choice}" ;;
    esac
  done
}

install_dialog
run_tasks
echo "All selected tasks completed. Reboot is recommended."
