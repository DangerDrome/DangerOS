# Rocky Install Guide

## 1. Install Minimal

> [!TIP]
> Grab the Rocky Linux `Minimal` ISO file from [here](https://rockylinux.org/download)
After the minimal install, login using root user/password and Update stuff:
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

## enable ssh for root:

### Open the ssh config file:
```
nano /etc/ssh/ssh_config
```
### Add this line and save it:
```
PermitRootLogin Yes
```
```
systemctl restart sshd
```
### View Status of ssh:
```
systemctl status sshd
# Get IP address
hostname -I
```
### Install VPN (tailscale in this case):
```
curl -fsSL https://tailscale.com/install.sh | sh
```
### follow the instructions for the vpn install

### install this GUI:
```
sudo dnf groupinstall "Server with GUI" -y
```
### Change the default boot to graphical mode:
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
### If the sound is not working run this command and reboot
```
sudo dnf install alsa-sof-firmware.noarch
```
## 2. Install Flatpak repo
https://flathub.org/
```
sudo dnf install flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
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

## 4. Install Houdini
Download and install houdini from the sidefx website & follow the instructions in the terminal

### Things that sidefx fails to mention in order to get houdini to run:
```
sudo dnf install python3-qt5 -y 
sudo dnf install libXScrnSaver-devel-1.2.3-10.el9. -y
sudo dnf install libnsl -y
```
```
sudo reboot
```

## 5. Install Docker
```
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io -y
```
### Start and enable Docker to run on system boot:
```
sudo systemctl enable --now docker
```
### Once the Docker is in place, it is now time to deploy Dockge OR Portainer on Rocky Linux.

## 6. Install Portainer
To begin with, you need to create Portainer server data volume. Please note that Portainer requires persistent storage in order to maintain the database and configuration information it needs to function:
```
sudo docker volume create portainer_data
```
The volume should be created in somewhere like :
"/var/lib/docker/volumes/portainer_data/_data"
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
