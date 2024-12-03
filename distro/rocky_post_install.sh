#!/bin/bash
#
# linux-setup.sh
#
# (c) DangerOS>
#
# This script turns a minimal Rocky Linux 9.x installation into DangerOS.

# Current directory
CWD=$(pwd)

# Slow things down a bit
SLEEP=1

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
echo
echo "  ###############################"
echo "  # Rocky Linux ${VERSION} configuration #"
echo "  ###############################"
echo
sleep ${SLEEP}

# Defined users
USERS="$(awk -F: '$3 > 999 {print $1}' /etc/passwd | sort)"

# Admin user
ADMIN=$(getent passwd 1000 | cut -d: -f 1)

# Remove these packages
CRUFT=$(egrep -v '(^\#)|(^\s+$)' ${CWD}/dnf/useless-packages.txt)

# Install these packages
EXTRA=$(egrep -v '(^\#)|(^\s+$)' ${CWD}/dnf/extra-packages.txt)

# Enhanced base system
BASE=$(egrep -v '(^\#)|(^\s+$)' ${CWD}/dnf/enhanced-base.txt)

# Mirrors
DOCKER="https://download.docker.com/linux/centos"
CISOFY="https://packages.cisofy.com"
ICINGA="https://packages.icinga.com"

# Log
LOG="/tmp/$(basename "${0}" .sh).log"
echo > ${LOG}

usage() {
  # Display help message
  echo "  Usage: ${0} OPTION"
  echo
  echo "  Rocky Linux ${VERSION} post-install configuration for servers."
  echo
  echo "  Options:"
  echo
  echo "    --shell    Configure shell: Bash, Vim, console, etc."
  echo "    --repos    Setup official and third-party repositories."
  echo "    --fresh    Sync repositories and fetch updates."
  echo "    --extra    Install enhanced base system."
  echo "    --strip    Remove unneeded system components."
  echo "    --logs     Enable admin user to access system logs."
  echo "    --ipv4     Disable IPv6 and reconfigure basic services."
  echo "    --sudo     Configure persistent password for sudo."
  echo "    --setup    Perform all of the above in one go."
  echo "    --reset    Revert back to enhanced base system."
  echo
  echo "  Logs are written to ${LOG}."
  echo
}

configure_shell() {
  echo "  === Shell configuration ==="
  echo
  sleep ${SLEEP}
  # Install custom command prompts and a handful of nifty aliases.
  echo "  Configuring Bash shell for user: root"
  cat ${CWD}/bash/bashrc-root > /root/.bashrc
  sleep ${SLEEP}
  echo "  Configuring Bash shell for future users."
  cat ${CWD}/bash/bashrc-users > /etc/skel/.bashrc
  sleep ${SLEEP}
  # Existing users might want to use it.
  if [ ! -z "${USERS}" ]
  then
    for USER in ${USERS}
    do
      if [ -d /home/${USER} ]
      then
        echo "  Configuring Bash shell for user: ${USER}"
        cat ${CWD}/bash/bashrc-users > /home/${USER}/.bashrc
        chown ${USER}:${USER} /home/${USER}/.bashrc
        sleep ${SLEEP}
      fi
    done
  fi
  # Add a handful of nifty system-wide options for Vim.
  echo "  Configuring system-wide options for Vim."
  cat ${CWD}/vim/vimrc > /etc/vimrc
  sleep ${SLEEP}
  # Set english as main system language.
  echo "  Configuring system locale."
  localectl set-locale LANG=en_US.UTF-8
  sed -i -e '/AcceptEnv/s/^#\?/#/' /etc/ssh/sshd_config
  systemctl reload sshd
  sleep ${SLEEP}
  echo
}

configure_repos() {
  echo " === Package repository configuration ==="
  echo 
  sleep ${SLEEP}
  echo "  Removing existing repositories."
  rm -f /etc/yum.repos.d/*.repo
  rm -f /etc/yum.repos.d/*.repo.rpmsave
  sleep ${SLEEP}
  # Enable [baseos], [appstream], [extras] and [powertools] repositories with a
  # priority of 1.
  for REPOSITORY in BaseOS AppStream Extras PowerTools
  do
    echo "  Configuring repository: ${REPOSITORY}"
    cp ${CWD}/dnf/Rocky-${REPOSITORY}.repo /etc/yum.repos.d/
    sleep ${SLEEP}
  done
  # Enable [epel] and [epel-modular] repositories with a priority of 10.
  if ! rpm -q epel-release > /dev/null 2>&1
  then
    echo "  Installing repository: EPEL" 
    dnf -y install epel-release >> ${LOG} 2>&1
  fi
  echo "  Configuring repository: EPEL" 
  cat ${CWD}/dnf/epel.repo > /etc/yum.repos.d/epel.repo
  sleep ${SLEEP}
  echo "  Configuring repository: EPEL Modular" 
  cat ${CWD}/dnf/epel-modular.repo > /etc/yum.repos.d/epel-modular.repo
  sleep ${SLEEP}
  echo "  Removing repository: EPEL Testing"
  rm -f /etc/yum.repos.d/epel-testing.repo
  sleep ${SLEEP}
  echo "  Removing repository: EPEL Testing Modular"
  rm -f /etc/yum.repos.d/epel-testing-modular.repo
  sleep ${SLEEP}
  echo "  Removing repository: EPEL Playground"
  rm -f /etc/yum.repos.d/epel-playground.repo
  sleep ${SLEEP}
  # Configure [elrepo] repository.
  if ! rpm -q elrepo-release > /dev/null 2>&1
  then
    echo "  Installing repository: ELRepo"
    dnf -y install elrepo-release >> ${LOG} 2>&1
  fi
  echo "  Configuring repository: ELRepo"
  cat ${CWD}/dnf/elrepo.repo > /etc/yum.repos.d/elrepo.repo
  sleep ${SLEEP}
  # Enable [lynis] repo with a priority of 5.
  echo "  Configuring repository: Lynis"
  rpm --import ${CISOFY}/keys/cisofy-software-rpms-public.key >> ${LOG} 2>&1
  cat ${CWD}/dnf/lynis.repo > /etc/yum.repos.d/lynis.repo
  sleep ${SLEEP}
  # Configure [icinga] repository without enabling it.
  if ! rpm -q icinga-rpm-release > /dev/null 2>&1
  then
    echo "  Installing repository: Icinga"
    dnf -y install ${ICINGA}/epel/icinga-rpm-release-8-latest.noarch.rpm >> ${LOG} 2>&1
  fi
  echo "  Configuring repository: Icinga"
  cat ${CWD}/dnf/ICINGA-release.repo > /etc/yum.repos.d/ICINGA-release.repo
  rm -f /etc/yum.repos.d/ICINGA-snapshot.repo
  sleep ${SLEEP}
  # Configure [docker] repository with a priority of 10.
  echo "  Configuring repository: Docker"
  rpm --import ${DOCKER}/gpg >> ${LOG} 2>&1
  cat ${CWD}/dnf/docker-ce.repo > /etc/yum.repos.d/docker-ce.repo
  sleep ${SLEEP}
  echo
}

update_system() {
  echo "  === Update system ==="
  echo
  sleep ${SLEEP}
  if ! rpm -q drpm > /dev/null 2>&1
  then
    echo "  Enabling Delta RPM."
    dnf -y install drpm >> ${LOG} 2>&1
  fi
  # Update system.
  echo "  Performing system update."
  sleep ${SLEEP}
  echo "  This might take a moment..."
  dnf -y update >> ${LOG} 2>&1
  echo
}

install_extras() {
  echo "  === Install extra packages ==="
  echo
  sleep ${SLEEP}
  echo "  Fetching missing packages from Core package group." 
  dnf -y group mark remove "Core" >> ${LOG} 2>&1
  dnf -y group install "Core" >> ${LOG} 2>&1
  echo "  Core package group installed on the system."
  sleep ${SLEEP}
  echo "  Installing Base package group."
  sleep ${SLEEP}
  echo "  This might take a moment..."
  dnf -y group mark remove "Base" >> ${LOG} 2>&1
  dnf -y group install "Base" >> ${LOG} 2>&1
  echo "  Base package group installed on the system."
  sleep ${SLEEP}
  echo "  Installing some additional packages."
  sleep ${SLEEP}
  for PACKAGE in ${EXTRA}
  do
    if ! rpm -q ${PACKAGE} > /dev/null 2>&1
    then
      echo "  Installing package: ${PACKAGE}"
      dnf -y install ${PACKAGE} >> ${LOG} 2>&1
    fi
  done
  echo "  Additional packages installed on the system."
  echo
  sleep ${SLEEP}
}

remove_cruft() {
  echo "  === Remove useless packages ==="
  echo
  sleep ${SLEEP}
  echo "  Removing unneeded components from the system."
  sleep ${SLEEP}
  for PACKAGE in ${CRUFT}
  do
    if rpm -q ${PACKAGE} > /dev/null 2>&1
    then
      echo "  Removing package: ${PACKAGE}"
      dnf -y remove ${PACKAGE} >> ${LOG} 2>&1
      if [ "${?}" -ne 0 ]
        then
        echo "  Could not remove package ${PACKAGE}." >&2
        exit 1
      fi
    fi
  done
  echo "  Unneeded components removed from the system."
  echo
  sleep ${SLEEP}
}

configure_logs() {
  echo "  === Configure logging ==="
  echo
  sleep ${SLEEP}
  # Admin user can access system logs
  if [ ! -z "${ADMIN}" ]
  then
    if getent group systemd-journal | grep ${ADMIN} > /dev/null 2>&1
    then
      echo "  Admin user ${ADMIN} is already a member of the systemd-journal group."
    else
      echo "  Adding admin user ${ADMIN} to systemd-journal group."
      usermod -a -G systemd-journal ${ADMIN}
    fi
  fi
  echo
  sleep ${SLEEP}
}

disable_ipv6() {
  echo "  === Use IPv4 only ==="
  echo
  sleep ${SLEEP}
  # Disable IPv6
  echo "  Disabling IPv6."
  sleep ${SLEEP}
  cat ${CWD}/sysctl.d/disable-ipv6.conf > /etc/sysctl.d/disable-ipv6.conf
  sysctl -p --load /etc/sysctl.d/disable-ipv6.conf >> $LOG 2>&1
  # Reconfigure SSH 
  if [ -f /etc/ssh/sshd_config ]
  then
    echo "  Configuring SSH server for IPv4 only."
    sleep ${SLEEP}
    sed -i -e 's/#AddressFamily any/AddressFamily inet/g' /etc/ssh/sshd_config
    sed -i -e 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g' /etc/ssh/sshd_config
    systemctl reload sshd
  fi
  # Reconfigure Postfix
  if [ -f /etc/postfix/main.cf ]
  then
    echo "  Configuring Postfix server for IPv4 only."
    sleep ${SLEEP}
    sed -i -e 's/# Enable IPv4, and IPv6 if supported/# Enable IPv4/g' /etc/postfix/main.cf
    sed -i -e 's/inet_protocols = all/inet_protocols = ipv4/g' /etc/postfix/main.cf
    systemctl restart postfix
  fi
  # Rebuild initrd
  echo "  Rebuilding initial ramdisk."
  dracut -f -v >> $LOG 2>&1
  echo
}

configure_sudo() {
  echo "  === Configure sudo ==="
  echo
  sleep ${SLEEP}
  echo "  Configuring persistent password for sudo."
  cat ${CWD}/sudoers.d/persistent_password > /etc/sudoers.d/persistent_password
  echo
  sleep ${SLEEP}
}

reset_system() {
  echo "  === Restore enhanced base system ==="
  echo
  sleep ${SLEEP}
  # Display all packages that are not part of the enhanced base system.
  echo "  Creating database."
  local TMP="/tmp"
  local PKGLIST="${TMP}/pkglist"
  local PKGINFO="${TMP}/pkg_base"
  rpm -qa --queryformat '%{NAME}\n' | sort > ${PKGLIST}
  PACKAGES=$(egrep -v '(^\#)|(^\s+$)' $PKGLIST)
  rm -rf ${PKGLIST} ${PKGINFO}
  mkdir ${PKGINFO}
  unset REMOVE
  for PACKAGE in ${BASE}
  do
    touch ${PKGINFO}/${PACKAGE}
  done
  for PACKAGE in ${PACKAGES}
  do
    if [ -r ${PKGINFO}/${PACKAGE} ]
    then
      continue
    else
      REMOVE="${REMOVE}\n  * ${PACKAGE}"
    fi
  done
  if [ ! -z "${REMOVE}" ]
  then
    echo
    echo "  The following packages are not part of the enhanced base system:"
    echo -e "${REMOVE}"
  fi
  rm -rf ${PKGLIST} ${PKGINFO}
  echo
}

# Check parameters.
if [[ "${#}" -ne 1 ]]
then
  usage
  exit 1
fi
OPTION="${1}"
case "${OPTION}" in
  --shell)
    configure_shell
    ;;
  --repos)
    configure_repos
    ;;
  --fresh)
    update_system
    ;;
  --extra)
    install_extras
    ;;
  --strip)
    remove_cruft
    ;;
  --logs) 
    configure_logs
    ;;
  --ipv4) 
    disable_ipv6
    ;;
  --sudo) 
    configure_sudo
    ;;
  --setup) 
    configure_shell
    configure_repos
    update_system
    install_extras
    remove_cruft
    configure_logs
    disable_ipv6
    configure_sudo
    ;;
  --reset) 
    reset_system
    ;;
  --help) 
    usage
    exit 0
    ;;
  ?*) 
    usage
    exit 1
esac

exit 0

