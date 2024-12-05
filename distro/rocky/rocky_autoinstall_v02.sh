#!/bin/bash

# rocky_autoinstall.sh
# Modular Auto Install Script for Rocky Linux 9.x

#############################
# Variables
#############################
P="[>] "
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
    echo "${P} Installing dialog for interactive menu..."
    sudo dnf install dialog -y
  fi
}

check_prerequisites() {
  if [[ "${UID}" -ne 0 ]]; then
    echo "${P} Please run this script as root or with sudo." >&2
    exit 1
  fi

  echo "${P} Checking for EPEL repository..."
  if ! rpm -q epel-release >/dev/null; then
    sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
  fi
}

optimize_dnf() {
  echo "${P} Optimizing DNF for faster performance..."

  # Path to the DNF configuration file
  DNF_CONF="/etc/dnf/dnf.conf"

  # Backup the original configuration
  if [[ ! -f "${DNF_CONF}.backup" ]]; then
    echo "${P} Creating a backup of the current DNF configuration..."
    sudo cp "${DNF_CONF}" "${DNF_CONF}.backup"
  fi

  # Apply optimizations
  echo "${P} Applying performance optimizations to ${DNF_CONF}..."
  sudo tee -a "${DNF_CONF}" > /dev/null <<EOF

# Optimization settings
fastestmirror=True
max_parallel_downloads=10
keepcache=True
EOF

  # Notify user
  echo "${P} DNF has been optimized with the following settings:"
  echo "${P}  - Enabled fastest mirror detection"
  echo "${P}  - Increased parallel downloads to 10"
  echo "${P}  - Enabled cache retention"
  echo "${P} You may now experience faster DNF commands."
}

setup_repositories() {
  echo "${P} Setting up repositories"

  # Enable CRB repository
  echo "${P} Enabling the CRB (CodeReady Builder) repository..."
  if sudo dnf config-manager --set-enabled crb; then
    # install epel repository
    if ! sudo dnf install -y epel-release; then
      echo "${P} Error: Failed to install epel-release package. Check the repository files and network connection."
      return 1
    fi
  else
    echo "${P} Error: Failed to enable the CRB repository. Please check your system configuration."
    return 1
  fi

  # Install Community Enterprise Linux Repository (ELRepo)
  echo "${P} Installing ELRepo for additional kernel modules..."
  
  if ! sudo dnf install -y elrepo-release; then
    echo "${P} Error: Failed to install elrepo-release package. Check the repository files and network connection."
    return 1
  fi

  echo "${P} ELRepo installed successfully."

  # Install RPM Fusion
  echo "${P} Installing RPM Fusion repository..."
  
  if ! sudo dnf install -y rpmfusion-free-release; then
    echo "${P} Error: Failed to install RPM Fusion free package. Check the repository files and network connection."
    return 1
  fi
  if ! sudo dnf install -y rpmfusion-nonfree-release; then
    # grab it from a different mirror
    if ! sudo dnf install -y ${FUSION}/nonfree/el/rpmfusion-nonfree-release-9.noarch.rpm; then
      echo "${P} Error: Failed to install RPM Fusion nonfree package. Check the repository files and network connection."
      return 1
    echo "${P} Switched to another mirror to install RPM Fusion nonfree package."
    fi
  fi 
  echo "${P} RPM Fusion free & nonfree installed successfully."

  # Install flatpak & flathub
  echo "${P} Installing Flatpak and Flathub..."
  if ! sudo dnf install -y flatpak; then
    echo "${P} Error: Failed to install Flatpak package. Check the repository files and network connection."
    return 1
  fi
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  echo "${P} Flatpak and Flathub installed successfully."

  # Refresh the repository cache
  echo "${P} Refreshing repository cache..."
  sudo dnf clean all
  sudo dnf makecache || {
    echo "${P} Error: Failed to refresh the repository cache. Check the repository files and network connection."
    return 1
  }

  # Notify user
  echo "${P} Repositories have been successfully set up from ${DNF_DIR}, and CRB is enabled."
  #dnf repolist
}

install_nvidia_drivers() {

  echo "${P} Installing NVIDIA drivers..."
  # Add NVIDIA repository
  sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo
  # Install required packages
  sudo dnf install kernel-headers-$(uname -r) kernel-devel-$(uname -r) tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglvnd-devel acpid pkgconfig dkms -y
  # Install NVIDIA driver
  sudo dnf module install nvidia-driver:latest-dkms -y
  # Blacklist nouveau driver
  echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
  echo 'omit_drivers+=" nouveau "' | sudo tee /etc/dracut.conf.d/blacklist-nouveau.conf
  # Regenerate initramfs
  sudo dracut --regenerate-all --force
  # Update module dependencies
  sudo depmod -a

  echo "${P} NVIDIA drivers installed successfully. Reboot and run nvidia-smi to verify."
  return 0
}

install_packages() {
  echo "${P} Installing base packages..."
  for PACKAGE in ${BASE}; do
    sudo dnf install -y ${PACKAGE}
  done
}

configure_system() {
  echo "${P} Configuring SSH and XRDP..."
  sudo systemctl enable --now sshd
  sudo systemctl enable --now xrdp
  sudo firewall-cmd --permanent --add-port=3389/tcp
  sudo firewall-cmd --reload
}

install_gnome_extensions() {
  echo "${P} Installing Extensions..."

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
      echo "${P} Error: Failed to install GNOME extension ${EXTENSION}."
      return 1
    fi

    # Then enable the extension
    #if ! sudo gnome-extensions enable ${EXTENSION}; then
    #  echo "Error: Failed to enable GNOME extension ${EXTENSION}."
    #  return 1
    #fi
  done

  echo "${P} GNOME extensions installed, need to logout and back in to enable them."
  return 0
}

install_docker() {
  echo "${P} Installing Docker..."
  sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl enable --now docker
  sudo usermod -aG docker ${USER}
  echo "${P} Docker installed successfully."

  # Install Dockge
  echo "${P} Installing Dockge..."
  sudo mkdir -p /opt/stacks /opt/dockge
  cd /opt/dockge
  sudo curl https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml --output compose.yaml
  sudo docker compose up -d
  cd ${CWD}
  echo "${P} Dockge installed successfully."
}

customize_environment() {
  echo "${P} Customizing Environment..."
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
  echo "${P} Mounting SMB network locations..."
  while IFS=, read -r SHARE MOUNT_POINT OPTIONS; do
    if [[ ! -d "${MOUNT_POINT}" ]]; then
      mkdir -p "${MOUNT_POINT}"
    fi
    mount -t cifs -o "${OPTIONS}" "//${SHARE}" "${MOUNT_POINT}"
  done < "${NETWORK_CONFIG}"
}

remove_rocky_wallpapers() {
  echo "${P} Removing Rocky Linux wallpapers..."

  # Define the directories where Rocky Linux wallpapers might be located
  WALLPAPER_DIRS=(
    "/usr/share/backgrounds"
  )

  # Loop through each directory and remove the wallpapers
  for DIR in "${WALLPAPER_DIRS[@]}"; do
    if [[ -d "${DIR}" ]]; then
      echo "${P} Removing wallpapers in ${DIR}..."
      sudo rm -rf "${DIR}"
    else
      echo "${P} Directory ${DIR} not found. Skipping..."
    fi
  done

  echo "${P} Rocky Linux wallpapers removed successfully."
  return 0
}

set_desktop_wallpaper() {
  echo "${P} Changing desktop wallpaper for all users..."

  # Define the path to the wallpaper in the branding directory
  WALLPAPER_FILE="${BRANDING_DIR}/wallpaper.jpg"

  # Set wallpaper for the current user
  echo "${P} Setting wallpaper for the current user..."
  gsettings set org.gnome.desktop.background picture-uri "file://${WALLPAPER_FILE}"
  gsettings set org.gnome.desktop.background picture-options "zoom"

  # Set wallpaper for all existing users
  echo "${P} Setting wallpaper for all users..."
  for USER in ${USERS}; do
    if [[ -d "/home/${USER}/.config" ]]; then
      su -c "gsettings set org.gnome.desktop.background picture-uri 'file://${WALLPAPER_FILE}'" "${USER}" 2>/dev/null || {
        echo "${P} Failed to set wallpaper for user: ${USER}. Skipping..."
      }
    fi
  done

  # Notify the user
  echo "${P} Wallpaper has been updated. Users may need to log out and log back in to see the changes."
}

white_label_os() {
  echo "${P} Applying white-label branding to Rocky Linux..."

  # Define paths for branding assets
  DANGER_LOGO=(
    "${BRANDING_DIR}/fedora-gdm-logo.png"
    "${BRANDING_DIR}/fedora-logo-small.png"
    "${BRANDING_DIR}/fedora-logo-sprite.png"
    "${BRANDING_DIR}/fedora-logo-sprite.svg"
    "${BRANDING_DIR}/rocky-logo.png"
    "${BRANDING_DIR}/system-logo-white.png"
  )

  ROCKY_LOGO=(
    "/usr/share/pixmaps/fedora-gdm-logo.png"
    "/usr/share/pixmaps/fedora-logo-small.png"
    "/usr/share/pixmaps/fedora-logo-sprite.png"
    "/usr/share/pixmaps/fedora-logo-sprite.svg"
    "/usr/share/pixmaps/rocky-logo.png"
    "/usr/share/pixmaps/system-logo-white.png"
  )

  # Replace ROCKY_LOGO with DANGER_LOGO
  for i in "${!DANGER_LOGO[@]}"; do
    if [[ -f "${DANGER_LOGO[$i]}" ]]; then
      sudo cp -f "${DANGER_LOGO[$i]}" "${ROCKY_LOGO[$i]}"
    else
      echo "${P} Error: Branding asset not found: ${DANGER_LOGO[$i]}. Skipping..."
    fi
  done

}

enable_dark_mode() {
  echo "${P} Enabling dark mode for GNOME desktop and applications globally..."

  # Ensure dconf CLI is installed
  if ! command -v dconf &>/dev/null; then
    echo "${P} Installing dconf to configure GNOME system settings..."
    sudo dnf install -y dconf
  fi

  # Enable dark mode for all Flatpak apps
  echo "${P} Enabling dark mode for Flatpak apps..."

  if ! flatpak override --env=GTK_THEME=Adwaita:dark; then
    echo "${P} Error: Failed to enable dark mode for Flatpak apps."
    return 1
  fi

  # Set system-wide GNOME desktop to dark mode
  echo "${P} Setting GNOME desktop interface to dark mode..."
  sudo mkdir -p /etc/dconf/db/local.d
  sudo tee /etc/dconf/db/local.d/00-dark-mode > /dev/null <<EOF
[org/gnome/desktop/interface]
gtk-theme='Adwaita-dark'
color-scheme='prefer-dark'

[org/gnome/shell/extensions/user-theme]
name='Adwaita-dark'
EOF

  # Apply changes
  echo "${P} Updating dconf database to apply dark mode settings..."
  sudo dconf update

  # Configure Flatpak apps to use dark mode
  echo "${P} Applying dark mode for Flatpak applications..."
  flatpak override --env=GTK_THEME=Adwaita:dark org.mozilla.firefox
  flatpak override --env=GTK_THEME=Adwaita:dark com.spotify.Client
  flatpak override --env=GTK_THEME=Adwaita:dark org.gnome.Calendar

  # Notify user
  echo "${P} Dark mode has been enabled system-wide. Please restart GNOME Shell or reboot the system to apply changes."
}

increase_scaling_factor() {
  echo "${P} Increasing scaling factor..."

  # Enable fractional scaling
  if ! gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"; then
    echo "${P} Error: Failed to enable fractional scaling."
    return 1
  fi

  # Set the scaling factor to 1.5
  if ! gsettings set org.gnome.desktop.interface text-scaling-factor 1.5; then
    echo "${P} Error: Failed to increase scaling factor."
    return 1
  fi

  echo "${P} Scaling factor increased successfully."
  return 0
}

set_nautilus_padding() {
  echo "${P} Setting universal padding for Nautilus..."

  # Set the padding for Nautilus
  if ! gsettings set org.gnome.nautilus.icon-view horizontal-icon-container-padding 100; then
    echo "${P} Error: Failed to set padding for Nautilus."
    return 1
  fi

  echo "${P} Nautilus padding set successfully."
  return 0
}

install_flatpak_apps() {
  echo "${P} Installing Apps..."
  for APP in ${FLATPAK}; do
    flatpak install -y ${APP}
  done
  echo "${P} Apps installed successfully."
}

#############################
# User Menu
#############################

run_tasks() {
  local tasks=(
    "1" "optimize_dnf" off
    "2" "setup_repositories" off
    "3" "install_nvidia_drivers" off
    "4" "install_packages" off
    "5" "configure_system (SSH/XRDP)" off
    "6" "install_gnome_extensions" off
    "7" "install_docker" off
    "8" "customize_environment" off
    "9" "auto_mount_network_locations" off
    "10" "remove_rocky_wallpapers" off
    "11" "set_desktop_wallpaper" off
    "12" "white_label_os" off
    "13" "enable_dark_mode" off
    "14" "increase_scaling_factor" off
    "15" "set_nautilus_padding" off
    "16" "install_flatpak_apps" off

  )
  
  local choices=$(dialog --separate-output --checklist "Select tasks to perform:" 20 50 12 "${tasks[@]}" 3>&1 1>&2 2>&3)
  
  clear
  check_prerequisites

  for choice in $choices; do
    case $choice in
      1) optimize_dnf ;;
      2) setup_repositories ;;
      3) install_nvidia_drivers ;;
      4) install_packages ;;
      5) configure_system ;;
      6) install_gnome_extensions ;;
      7) install_docker ;;
      8) customize_environment ;;
      9) auto_mount_network_locations ;;
      10) remove_rocky_wallpapers ;;
      11) set_desktop_wallpaper ;;
      12) white_label_os ;;
      13) enable_dark_mode ;;
      14) increase_scaling_factor ;;
      15) set_nautilus_padding ;;
      16) install_flatpak_apps ;;
      *) echo "Invalid option: ${choice}" ;;
    esac
  done
}

install_dialog
run_tasks
echo "${P} All selected tasks completed. Reboot is recommended!"
