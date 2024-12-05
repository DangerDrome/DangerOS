```
░█▀▄░█▀█░█▀█░█▀▀░█▀▀░█▀▄░█▀█░█▀▀
░█░█░█▀█░█░█░█░█░█▀▀░█▀▄░█░█░▀▀█
░▀▀░░▀░▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀
```
![image](https://github.com/user-attachments/assets/07cf9726-3a6a-4e57-87c0-71bc686ca5a2)
# Rocky Install Guide

## 1. Install Minimal

  > [!TIP]
  > Grab the Rocky Linux `Minimal` ISO file from [here](https://rockylinux.org/download)
  > After the minimal install, login using root user/password and Update stuff.
  
  ```
  dnf update -y
  ```
  <br>

### Enable ssh so you can copy paste stuff:
  ```
  systemctl start sshd
  ```
  ```
  systemctl enable sshd
  ```
  <br>

### Enable ssh for root.

  Open the ssh config file:
  ```
  nano /etc/ssh/ssh_config
  ```
  Add this line and save it:
  ```
  PermitRootLogin Yes
  ```
  ```
  systemctl restart sshd
  ```
  View Status of ssh:
  ```
  systemctl status sshd
  # Get IP address
  hostname -I
  ```
  <br>

### Install VPN.
  ```
  curl -fsSL https://tailscale.com/install.sh | sh
  ```
  > [!TIP]
  > Follow the instructions for the vpn install.
<br>

### Install the all the GUI packages:
  ```
  sudo dnf groupinstall "Server with GUI" -y
  ```
  Change the default boot to graphical mode:
  ```
  sudo systemctl set-default graphical.target
  ```
  ```
  sudo reboot
  ```
### Install xrdp (Remote Desktop):
  ```
  sudo dnf install epel-release -y
  sudo dnf install xrdp -y
  sudo systemctl start xrdp
  sudo systemctl enable xrdp
  sudo firewall-cmd --permanent --add-port=3389/tcp
  sudo firewall-cmd --reload
  ```
  <br>

### If the sound is not working run this command and reboot
  ```
  sudo dnf install alsa-sof-firmware.noarch
  ```
  <br>

## 2. Install Flatpak repo
  https://flathub.org/
  ```
  sudo dnf install flatpak
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  ```
  <br>

## 3. Install NVIDIA Drivers
  ```
  sudo dnf install epel-release 
  sudo dnf upgrade 
  sudo reboot
  ```
  ```
  sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo 
  sudo dnf install kernel-headers-$(uname -r) kernel-devel-$(uname -r) tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglvnd-devel acpid pkgconfig dkms -y
  sudo dnf module install nvidia-driver:latest-dkms -y 
  echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf 
  echo 'omit_drivers+=" nouveau "' | sudo tee /etc/dracut.conf.d/blacklist-nouveau.conf 
  sudo dracut --regenerate-all --force 
  sudo depmod -a
  ```
  ```
  sudo reboot
  ````
### After reboot, check the nvidia drivers install:
  ```
  nvidia-smi
  ```
### You should see something like this, and you're good:
  ```
  +---------------------------------------------------------------------------------------+
  | NVIDIA-SMI 545.23.06              Driver Version: 545.23.06    CUDA Version: 12.3     |
  |-----------------------------------------+----------------------+----------------------+
  | GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
  | Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
  |                                         |                      |               MIG M. |
  |=========================================+======================+======================|
  |   0  NVIDIA GeForce RTX 4090        Off | 00000000:00:10.0  On |                  Off |
  | 31%   25C    P8              33W / 450W |    231MiB / 24564MiB |      0%      Default |
  |                                         |                      |                  N/A |
  +-----------------------------------------+----------------------+----------------------+
  
  +---------------------------------------------------------------------------------------+
  | Processes:                                                                            |
  |  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
  |        ID   ID                                                             Usage      |
  |=======================================================================================|
  |    0   N/A  N/A      2476      G   /usr/libexec/Xorg                           200MiB |
  |    0   N/A  N/A      2833      G   /usr/bin/gnome-shell                         18MiB |
  +---------------------------------------------------------------------------------------+
  ```
  <br>

## 4. Install Houdini.

  > [!TIP]
  > Download and install houdini from the sidefx website & follow the instructions in the terminal
  > Here are some things that sidefx fails to mention in order to get houdini to run:
  <br>
  
  ```
  sudo dnf install python3-qt5 -y 
  sudo dnf install libXScrnSaver-devel-1.2.3-10.el9. -y
  sudo dnf install libnsl -y
  ```
  ```
  sudo reboot
  ```
  <br>

## 5. Install Docker.
  ```
  sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
  sudo dnf install docker-ce docker-ce-cli containerd.io -y
  ```
### Start and enable Docker to run on system boot:
  ```
  sudo systemctl enable --now docker
  ```
### Once the Docker is in place, it is now time to deploy Dockge OR Portainer on Rocky Linux.
<br>

## 6. Install Portainer.
  To begin with, you need to create Portainer server data volume. Please note that Portainer requires persistent storage in order to maintain the database and configuration information it needs to function:
  ```
  sudo docker volume create portainer_data
  ```
  <br>

  > [!TIP]
  > The volume should be created in somewhere like:
  > "/var/lib/docker/volumes/portainer_data/_data"
  <br>
  
  ```
  sudo docker volume inspect portainer_data
  ```
  ### install portainer into that volume:
  ```
  sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
  --restart=always -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce:latest
  ```
  ### To access Portainer server UI, then navigate to the browser and enter the address:
  ```
  https://localhost:9443/
  ```
  <br>
  
## 7. Auto Mount SMB shares.
make a file called `.smb` in the `~/` folder and add the following text with your `username` and `password` for the drive:
  ```
  username=<user>
  password=<pass>
  ```
Open `/etc/fstab` with nano:
  ```
  sudo nano /etc/fstab
  ```
And add the following lines somehwhere:
  ```
  # AUTOMOUNT
  # smb:
  //skeletor/jobs /home/danger/JOBS cifs credentials=/home/danger/.smb,uid=1000,gid=1000,vers=3.0,nounix 0 0
  //skeletor/io /home/danger/IO cifs credentials=/home/danger/.smb,uid=1000,gid=1000,vers=3.0,nounix 0 0
  ```
  <br>
  
## 8. Mount Drives.
Run the following command with your `username` and `password` for the drive:
  ```
  sudo dnf install smbclient -y 
  sudo dnf install cifs-utils -y

  # Checkout what shares are available:
  smbclient -L

  # Mount Example, Jobs folder Mount:
  sudo mount -t cifs -rw -o username=<Username> //<server>/<share> /home/danger/JOBS
  ```

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

