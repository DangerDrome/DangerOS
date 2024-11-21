#!/bin/bash
#░█▀▄░█▀█░█▀█░█▀▀░█▀▀░█▀▄░█▀█░█▀▀
#░█░█░█▀█░█░█░█░█░█▀▀░█▀▄░█░█░▀▀█
#░▀▀░░▀░▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀
# Bash script Aliases

# Save & Load terminal profiles
alias save='dconf dump /org/gnome/terminal/legacy/profiles:/ > ~/gnome-terminal-profiles.dconf; printf "\n ${bold}${rev} Saved! ${reset} Saved terminal theme to: ${bold}~/gnome-terminal-profiles.dconf\n"'
alias load='dconf load /org/gnome/terminal/legacy/profiles:/ < ~/gnome-terminal-profiles.dconf; printf "\n ${bold}${rev} Loaded! ${reset} Loaded terminal theme from: ${bold}~/gnome-terminal-profiles.dconf\n"'

#######################################################
# Variables
#######################################################
ver="1.0.1"

#######################################################
# Terminal Styles
#######################################################

# Text FG Colors
fg_black=$(tput setaf 0)
fg_red=$(tput setaf 1)
fg_green=$(tput setaf 2)
fg_yellow=$(tput setaf 3)
fg_blue=$(tput setaf 4)
fg_pink=$(tput setaf 5)
fg_cyan=$(tput setaf 6)
fg_grey=$(tput setaf 7)

# Text BG Colors
bg_black=$(tput setab 0)
bg_red=$(tput setab 1)
bg_green=$(tput setab 2)
bg_yellow=$(tput setab 3)
bg_blue=$(tput setab 4)
bg_pink=$(tput setab 5)
bg_cyan=$(tput setab 6)
bg_grey=$(tput setab 7)

# Text Attributes
reset=$(tput sgr0)
bold=$(tput bold)
dim=$(tput dim)
italic=$(tput sitm)
underline=$(tput smul)
blink=$(tput blink)
rev=$(tput rev)
strike=$(tput smxx)

# Tests
# printf "${reset}${bold}bold\n"
# printf "${reset}${dim}dim\n"
# printf "${reset}${italic}italic\n"
# printf "${reset}${underline}underlined\n"
# printf "${reset}${blink}blinking\n"
# printf "${reset}${rev}reversed\n"
# printf "${reset}${strike}strikethrough\n${reset}\n"

# echo -e "\033[0mNC (No color)"
# echo -e "\033[1;37mWHITE\t\033[0;30mBLACK"
# echo -e "\033[0;34mBLUE\t\033[1;34mLIGHT_BLUE"
# echo -e "\033[0;32mGREEN\t\033[1;32mLIGHT_GREEN"
# echo -e "\033[0;36mCYAN\t\033[1;36mLIGHT_CYAN"
# echo -e "\033[0;31mRED\t\033[1;31mLIGHT_RED"
# echo -e "\033[0;35mPURPLE\t\033[1;35mLIGHT_PURPLE"
# echo -e "\033[0;33mYELLOW\t\033[1;33mLIGHT_YELLOW"
# echo -e "\033[1;30mGRAY\t\033[0;37mLIGHT_GRAY"

# General aliases
alias ff='fastfetch --logo /home/danger/logo_02.txt'
alias neofetch='fastfetch --logo /home/danger/logo_02.txt'

# Changing "ls" to "exa" a fancy lister with icons
alias ls='printf "\n${fg_black}${rev}█▓▒░ "; pwd; printf "\n${reset}"; exa --icons --color=always --group-directories-first; printf "${reset}\n"'
alias ll='printf "\n${fg_black}${rev}█▓▒░ "; pwd; printf "\n${reset}"; exa -alF --icons --color=always --group-directories-first; printf "\n"; printf "${fg_black}${rev}█▓▒░ [Size:$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed "s/total //") | Files:$(/bin/ls -A -1 | /usr/bin/wc -l)] "; printf "${reset}\n"'
alias la='printf "\n${fg_black}${rev}█▓▒░ "; pwd; printf "\n${reset}"; exa -a --icons --color=always --group-directories-first; printf "${reset}\n"'
alias l='printf "\n${fg_black}${rev}█▓▒░ "; pwd; printf "\n${reset}"; exa -F --icons --color=always --group-directories-first; printf "${reset}\n"'
alias l.='printf "\n${fg_black}${rev}█▓▒░ "; pwd; printf "\n${reset}"; exa -a | egrep "^\."${reset}'

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
alias ip='printf "\n${fg_green}█▓▒░  Hostname |  ";hostname -b;printf "${blue}█▓▒░ Tailscale | "; hostname -f; '

# Directories
alias home='cd ~'
alias h='home'
alias root='cd /'
alias dtop='cd ~/Desktop'
alias d='dtop'
alias dload='cd ~/Downloads'
alias dl='dload'
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
alias mx='sudo chmod a+x'
alias 000='sudo chmod -R 000'
alias 644='sudo chmod -R 644'
alias 666='sudo chmod -R 666'
alias 755='sudo chmod -R 755'
alias 777='sudo chmod -R 777'

# dnf stuff
alias update='sudo dnf update -y'
alias install='sudo dnf install -y'

# GTK CSS Overrides
alias css='sudo nano ~/.config/gtk-4.0/gtk.css'

# ohmyposh list themes
# alias themes='printf "\n[>] Listing Oh-My-Posh Themes: \n\n"; ls ~/.poshthemes; printf "\n"'

# Reload shell
alias reload='printf "\n${fg_black}${rev}█▓▒░ ${blink}Terminal Reloaded. ${reset}"; exec bash'
alias r='c; reload'
alias u='usage'

#Use this for when the boss comes around to look busy.
alias busy="cat /dev/urandom | hexdump -C | grep 'ca fe'" 


#######################################################
# SPECIAL FUNCTIONS
#######################################################



# Information
usage()
{
# all_aliases=$(compgen -a)
cat << EOF
${fg_green}${bold}

		░█▀▄░█▀█░█▀█░█▀▀░█▀▀░█▀▄░█▀█░█▀▀
		░█░█░█▀█░█░█░█░█░█▀▀░█▀▄░█░█░▀▀█
		░▀▀░░▀░▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀
		 ${dim}${rev}█▓▒░  ${blink}Welcome to DangerOS${reset}${bold}${dim}${rev}  ░▒▓█${reset}${bold}

╔════════════════╦═══════════════╦═══════════════════════════╗
║    Command     ║     Flag      ║        Description        ║
╠════════════════╬═══════════════╬═══════════════════════════╣
║ h              ║      --       ║ ~/Home Directory          ║
║ d              ║      --       ║ ~/Desktop Directory       ║
║ dl             ║      --       ║ ~/Downloads Directory     ║
║ root           ║      --       ║ ~/Root Directory          ║
║ f              ║     stuff     ║ Search for stuff          ║
║ ip	         ║      --       ║ List Network Information  ║
║ 777	         ║   filename    ║ Make File executable      ║
╚════════════════╩═══════════════╩═══════════════════════════╝

EOF
}

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
cat << EOF
${fg_green}${bold}
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
    ░▓███████                                                          ░▀▀▀░▀▀▀ v${ver}
  ░▓███████
  ■▓██▒░░░
  ░░▒


EOF
