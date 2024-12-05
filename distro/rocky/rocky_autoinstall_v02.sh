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
BRANDING_DIR="${CWD}/media/brand"
DNF_DIR="${CWD}/dnf"

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
  echo "Setting up repositories"

  # Enable CRB repository
  echo "Enabling the CRB (CodeReady Builder) repository..."
  if sudo dnf config-manager --set-enabled crb; then
    # install epel repository
    if ! sudo dnf install -y epel-release; then
      echo "Error: Failed to install epel-release package. Check the repository files and network connection."
      return 1
    fi
  else
    echo "Error: Failed to enable the CRB repository. Please check your system configuration."
    return 1
  fi

  # Install Community Enterprise Linux Repository (ELRepo)
  echo "Installing ELRepo for additional kernel modules..."
  
  if ! sudo dnf install -y elrepo-release; then
    echo "Error: Failed to install elrepo-release package. Check the repository files and network connection."
    return 1
  fi

  echo "ELRepo installed successfully."

  # Install RPM Fusion
  echo "Installing RPM Fusion repository..."
  
  if ! sudo dnf install -y rpmfusion-free-release; then
    echo "Error: Failed to install RPM Fusion free package. Check the repository files and network connection."
    return 1
  fi
  if ! sudo dnf install -y rpmfusion-nonfree-release; then
    # grab it from a different mirror
    if ! sudo dnf install -y ${FUSION}/nonfree/el/rpmfusion-nonfree-release-9.noarch.rpm; then
      echo "Error: Failed to install RPM Fusion nonfree package. Check the repository files and network connection."
      return 1
    echo "Switched to another mirror to install RPM Fusion nonfree package."
    fi
  fi 
  echo "RPM Fusion free & nonfree installed successfully."

  # Install flatpak & flathub
  echo "Installing Flatpak and Flathub..."
  if ! sudo dnf install -y flatpak; then
    echo "Error: Failed to install Flatpak package. Check the repository files and network connection."
    return 1
  fi
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  echo "Flatpak and Flathub installed successfully."

  # Refresh the repository cache
  echo "Refreshing repository cache..."
  sudo dnf clean all
  sudo dnf makecache || {
    echo "Error: Failed to refresh the repository cache. Check the repository files and network connection."
    return 1
  }

  # Notify user
  echo "Repositories have been successfully set up from ${DNF_DIR}, and CRB is enabled."
  #dnf repolist
}




install_packages() {
  echo "Installing base packages..."
  for PACKAGE in ${BASE}; do
    sudo dnf install -y ${PACKAGE}
  done
}

# install GNOME extensions from gnome.txt

install_gnome_extensions() {
  echo "Installing Extensions..."

  # List of GNOME extensions to install
  GNOME_EXTENSIONS=(
    "dash-to-panel"
    "workspace-indicator"
    "systemMonitor"
    "panel-favorites"
    "appindicator"
    "screenshot-window-sizer"
    "custom-menu"
  )

  for EXTENSION in "${GNOME_EXTENSIONS[@]}"; do
    # First install the extension using dnf with a wildcard for the version
    if ! sudo dnf install -y gnome-shell-extension-${EXTENSION}-*; then
      echo "Error: Failed to install GNOME extension ${EXTENSION}."
      return 1
    fi

    # Then enable the extension
    #if ! sudo gnome-extensions enable ${EXTENSION}; then
    #  echo "Error: Failed to enable GNOME extension ${EXTENSION}."
    #  return 1
    #fi
  done

  echo "GNOME extensions installed, need to logout and back in to enable them."
  return 0
}

install_flatpak_apps() {
  echo "Installing Apps..."
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
  echo "Customizing Environment..."
  cp -f ${CWD}/bash/bashrc /root/.bashrc
  cp -f ${CWD}/bash/bash_aliases /root/.bash_aliases
  for USER in ${USERS}; do
    if [[ -d /home/${USER} ]]; then
      cp -f ${CWD}/bash/bashrc /home/${USER}/.bashrc
      cp -f ${CWD}/bash/bash_aliases /home/${USER}/.bash_aliases
      chown ${USER}:${USER} /home/${USER}/.bashrc /home/${USER}/.bash_aliases
    fi
  done
  # Copy fastfetch logo
  cp -f ${CWD}/media/brand/logo.txt /usr/share/pixmaps/fastfetch-logo.png

  # Get Meslo nerd font:
  wget -O /usr/share/fonts/Meslo.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Meslo.zip \
  && unzip /usr/share/fonts/Meslo.zip -d /usr/share/fonts/ \
  && rm /usr/share/fonts/Meslo.zip \
  && fc-cache -f -v

  # Get rocky font
  # sudo wget -O /usr/share/fonts/rocky.zip https://github.com/DangerDrome/DangerOS/blob/main/distro/rocky/media/fonts/rocky.zip \
  && sudo unzip ${CWD}/media/fonts/rocky.zip -d /usr/share/fonts/ \
  && sudo fc-cache -f -v
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
  echo "Wallpaper has been updated. Users may need to log out and log back in to see the changes."
}

enable_dark_mode() {
  echo "Enabling dark mode for GNOME desktop and applications globally..."

  # Ensure dconf CLI is installed
  if ! command -v dconf &>/dev/null; then
    echo "Installing dconf to configure GNOME system settings..."
    sudo dnf install -y dconf
  fi

  # Enable dark mode for all Flatpak apps
  echo "Enabling dark mode for Flatpak apps..."

  if ! flatpak override --env=GTK_THEME=Adwaita:dark; then
    echo "Error: Failed to enable dark mode for Flatpak apps."
    return 1
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

optimize_dnf() {
  echo "Optimizing DNF for faster performance..."

  # Path to the DNF configuration file
  DNF_CONF="/etc/dnf/dnf.conf"

  # Backup the original configuration
  if [[ ! -f "${DNF_CONF}.backup" ]]; then
    echo "Creating a backup of the current DNF configuration..."
    sudo cp "${DNF_CONF}" "${DNF_CONF}.backup"
  fi

  # Apply optimizations
  echo "Applying performance optimizations to ${DNF_CONF}..."
  sudo tee -a "${DNF_CONF}" > /dev/null <<EOF

# Optimization settings
fastestmirror=True
max_parallel_downloads=10
keepcache=True
EOF

  # Notify user
  echo "DNF has been optimized with the following settings:"
  echo "  - Enabled fastest mirror detection"
  echo "  - Increased parallel downloads to 10"
  echo "  - Enabled cache retention"
  echo "You may now experience faster DNF commands."
}

increase_scaling_factor() {
  echo "Increasing scaling factor..."

  # Enable fractional scaling
  if ! gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"; then
    echo "Error: Failed to enable fractional scaling."
    return 1
  fi

  # Set the scaling factor to 1.5
  if ! gsettings set org.gnome.desktop.interface text-scaling-factor 1.5; then
    echo "Error: Failed to increase scaling factor."
    return 1
  fi

  echo "Scaling factor increased successfully."
  return 0
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
    "14" "Optimize DNF for faster commands" off

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
      14) optimize_dnf ;;
      *) echo "Invalid option: ${choice}" ;;
    esac
  done
}

install_dialog
run_tasks
echo "All selected tasks completed. Reboot is recommended."
