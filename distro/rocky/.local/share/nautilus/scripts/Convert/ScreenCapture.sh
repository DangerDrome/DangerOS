#!/bin/bash

#################################################
#	ScreenCapture v1.0 by Cooleech		#
#	GPLv3! Use it at your own risk!		#
#################################################

###### further tweaked by Inameiname
###### 11 September 2011

# Check ffmpeg
which ffmpeg
if [ $? != 0 ]; then
	zenity --question --text "Your system needs ffmpeg package.\nWould you like to install ffmpeg now?"
	if [ $? = 0 ]; then
		xterm -e "sudo aptitude -y install ffmpeg"
		which ffmpeg
		if [ $? = 0 ]; then
			zenity --info --text "Ffmpeg status:\n\nInstallation successful!" --timeout=3
			# Dependencies installed info
			echo "FFMPEG_INSTALLED=TRUE" > /home/$USER/.ScreenCapture/setup.rc
		else
			zenity --error --text "Ffmpeg status:\n\nInstallation unsuccessful!\nPlease try to installing it manualy!"
			exit 1
		fi
	else
		exit 1
	fi
fi

# Check and try to get screen resolution
which xrandr
if [ $? = 0 ]; then
	SCREEN_RES=`xrandr | grep '*'`
	SCREEN_RES="${SCREEN_RES/    */}"
	SCREEN_RES="${SCREEN_RES// /}"
else
	zenity --warning --text "Error occured during detecting screen resolution!
Capture resolution is now set to 1024x768."
	SCREEN_RES="1024x768"
fi

# Resolution and fps mods
RES=`zenity --width=485 --height=320 --list --radiolist --title="ScreenCapture 1.0" --text="Pick video resolution (<b>MAX: $SCREEN_RES</b>)" \
		--column " ? " --column "Type" --column "Resolution and fps" FALSE "PAL" "720x576 @ 25 fps, captures only part of screen" \
			FALSE "NTSC" "720x480 @ 30 fps, captures only part of screen" FALSE "Custom_PAL" "???x??? @ 25 fps" \
			FALSE "Custom_NTSC" "???x??? @ 30 fps" FALSE "Detected_PAL" "$SCREEN_RES @ 25 fps" TRUE "Detected_NTSC" "$SCREEN_RES @ 30 fps"`

# Load selected params
case $RES in
PAL*)
RES="720x576"
FPS="25"
;;
NTSC*)
RES="720x480"
FPS="30"
;;
Custom_PAL*)
RES=`zenity --entry --title="Width and Height" --text "Must be WxH, and dividable by 2\n(MAXIMUM $SCREEN_RES)" --entry-text="$SCREEN_RES"`
if [ $? != 0 ]; then
	exit 1
fi
FPS="25"
;;
Custom_NTSC*)
RES=`zenity --entry --title="Width and Height" --text "Must be WxH, and dividable by 2\n(MAXIMUM $SCREEN_RES)" --entry-text="$SCREEN_RES"`
if [ $? != 0 ]; then
	exit 1
fi
FPS="30"
;;
Detected_PAL*)
RES="$SCREEN_RES"
FPS="25"
;;
Detected_NTSC*)
RES="$SCREEN_RES"
FPS="30"
;;
*)
exit 1
;;
esac

# Self-explainable :)
SCRIPT_PATH_AND_NAME="$HOME/ScreenCapture-$RES@${FPS}fps"

# Make capture script
echo "#!/bin/bash

ffmpeg -f x11grab -s $RES -r $FPS -i :0.0 -sameq \$HOME/ScreenCapture.mpg
exit 0" > $SCRIPT_PATH_AND_NAME
chmod 777 $SCRIPT_PATH_AND_NAME # Make it executable

# Show info
zenity --info --title="$RES@${FPS}fps - ScreenCapture 1.0" --text "Stop capture with <b>q</b> (quit) in terminal!
Also you can open terminal and type: <b>killall ffmpeg</b>
Video file will be saved in <b>/home/$USER</b> folder!\n
Click 'Ok' to start capture or\nclose this window to postpone it."
if [ $? = 0 ]; then
	xterm -e $SCRIPT_PATH_AND_NAME
	rm -f $SCRIPT_PATH_AND_NAME # Comment this if you don't wish to auto-erase created script
fi

exit 0 # Magic!

