# General aliases
alias ff='fastfetch --logo /home/danger/logo_02.txt'
alias neofetch='fastfetch --logo /home/danger/logo_02.txt'

# alias ls='ls --color=auto'
# alias ll='ls -alF'
# alias la='ls -A'
# alias l='ls -CF'

# Changing "ls" to "exa" a fancy lister with icons
blue=$(tput setaf 4)
alias ls='printf "\n"; exa --icons --color=always --group-directories-first; printf "\n"'
alias ll='printf "\n"; exa -alF --icons --color=always --group-directories-first; printf "\n"; printf "${blue}█▓▒░ [Size:$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed "s/total //") | Files:$(/bin/ls -A -1 | /usr/bin/wc -l)]"; printf "\n"'
alias la='printf "\n"; exa -a --icons --color=always --group-directories-first; printf "\n"'
alias l='printf "\n"; exa -F --icons --color=always --group-directories-first; printf "\n"'
alias l.='printf "\n"; exa -a | egrep "^\."'

alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -iv'
alias mkdir='mkdir -p'

# Network stuff
alias ping='ping -c 5'

# Directories
alias home='cd ~'
alias root='cd /'
alias dtop='cd ~/Desktop'
alias dload='cd ~/Downloads'
alias gdrive='cd /run/user/1000/gvfs/'

# Change Directories
alias cd..='cd ..'
alias c='clear'

# Search files in the current folder
alias f="find . | grep "

# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# dnf stuff
alias update='sudo dnf update -y'
alias install='sudo dnf install -y'

# GTK CSS Overrides
alias css='sudo nano ~/.config/gtk-4.0/gtk.css'

# ohmyposh list themes
alias themes='printf "\n[>] Listing Oh-My-Posh Themes: \n\n"; ls ~/.poshthemes; printf "\n"'

# Reload shell
alias reload='printf "\n[>] Reloading the shell... \n\n"; exec bash'
alias r='c; reload'

#Use this for when the boss comes around to look busy.
alias busy="cat /dev/urandom | hexdump -C | grep 'ca fe'" 


#######################################################
# SPECIAL FUNCTIONS
#######################################################


# Show the current distribution
distribution ()
{
	local dtype
	# Assume unknown
	dtype="unknown"
	
	# First test against Fedora / RHEL / CentOS / generic Redhat derivative
	if [ -r /etc/rc.d/init.d/functions ]; then
		source /etc/rc.d/init.d/functions
		[ zz`type -t passed 2>/dev/null` == "zzfunction" ] && dtype="redhat"
	
	# Then test against SUSE (must be after Redhat,
	# I've seen rc.status on Ubuntu I think? TODO: Recheck that)
	elif [ -r /etc/rc.status ]; then
		source /etc/rc.status
		[ zz`type -t rc_reset 2>/dev/null` == "zzfunction" ] && dtype="suse"
	
	# Then test against Debian, Ubuntu and friends
	elif [ -r /lib/lsb/init-functions ]; then
		source /lib/lsb/init-functions
		[ zz`type -t log_begin_msg 2>/dev/null` == "zzfunction" ] && dtype="debian"
	
	# Then test against Gentoo
	elif [ -r /etc/init.d/functions.sh ]; then
		source /etc/init.d/functions.sh
		[ zz`type -t ebegin 2>/dev/null` == "zzfunction" ] && dtype="gentoo"
	
	# For Mandriva we currently just test if /etc/mandriva-release exists
	# and isn't empty (TODO: Find a better way :)
	elif [ -s /etc/mandriva-release ]; then
		dtype="mandriva"

	# For Slackware we currently just test if /etc/slackware-version exists
	elif [ -s /etc/slackware-version ]; then
		dtype="slackware"

	fi
	echo $dtype
}


# Show the current version of the operating system
ver ()
{
	local dtype
	dtype=$(distribution)

	if [ $dtype == "redhat" ]; then
		if [ -s /etc/redhat-release ]; then
			cat /etc/redhat-release && uname -a
		else
			cat /etc/issue && uname -a
		fi
	elif [ $dtype == "suse" ]; then
		cat /etc/SuSE-release
	elif [ $dtype == "debian" ]; then
		lsb_release -a
	elif [ $dtype == "gentoo" ]; then
		cat /etc/gentoo-release
	elif [ $dtype == "mandriva" ]; then
		cat /etc/mandriva-release
	elif [ $dtype == "slackware" ]; then
		cat /etc/slackware-version
	else
		if [ -s /etc/issue ]; then
			cat /etc/issue
		else
			echo "Error: Unknown distribution"
			exit 1
		fi
	fi
}


# Preloader
#count=0
#total=100
#pstr="|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■|"

# while [ $count -lt $total ]; do
#  sleep 0.005 # this is work
#  count=$(( $count + 1 ))
#  pd=$(( $count * 250 / $total ))
#  printf "\r%3d.%1d%% %.${pd}s" $(( $count * 100 / $total )) $(( ($count * 1000 / $total) % 10 )) $pstr
# done

# Shell intro
printf "\n\n"
cat << "EOF"
                                                              ■██████■     
                                                          ████████████■   
                                                  ███████ █████    ███     
                                          █████  ███     ████    ███      
                            ■          █████  ████████████████  ████      
                            ███   ███  █████    ██████    ████ █████       
            ■█████████     ███ █   ██ █████     ███   ███████████         
          ░▒██████████████ ██  ██ ███ █████ █████████████████████          
        ░▒███████░░░▒██████████████████████  █████      ████ █████         
        ░███████    ▒██████████████ ███ ███████        █████  ██████       
        ░████      ░██████░░▒█████  █▓  ████          ████     █████       
        ░█████     ░██████   ░████  ▒                  ████      █████     
      ░▒█████     ░██████     ███   ░                 ███        ██████    
      ░██████      ░█████      ▓                     ████■          ██████ 
      ░█████    ░███████       ■                                     █████ 
      ░████    ░██████                                                 ██████■ ®
      ░████  ░███████                                                          
    ░▓████░████████                                                    ░█▀█░█▀▀
    ░▓███████████                                                      ░█░█░▀▀█
    ░▓███████                                                          ░▀▀▀░▀▀▀
  ░▓███████                                                              v0.7.1
  ■▓██▒░░░                
  ░░▒


EOF
info=$(ver)
# printf "${blue}${info}"