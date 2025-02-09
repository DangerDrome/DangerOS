#!/bin/bash

# S.S.Re (simply smart renamer) a simple tool to rename multiple files.
# This tool is a graphical fronted which uses Zenity and basic command
# line tools to rename multiple files.
# You must have zenity in your system.
# Author: TROiKAS troikas@pathfinder.gr

# To begin with, set the app title and version
TITLE="S.S.Re"
VERSION="1.0"

# Set window title and window width
WINDOW_TITLE=$TITLE" (v"$VERSION")"
WINDOW_WIDTH=325
WINDOW_HEIGHT=500

# Paths to needed executables. Please adjust as necessary
Zenity=/usr/bin/zenity
Printf=/usr/bin/printf
Ls=/bin/ls
Sed=/bin/sed
Mv=/bin/mv
Rm=/bin/rm
Notify=/usr/bin/notify-send

# Check if Zenity can be found. If not, produce error message
# (with "xmessage", since zenity is not available) and bail out
if [ ! -e "$Zenity" ]; then
xmessage "ERROR: $Zenity not found. You must install the Zenity\
package, or provide an alternative location"
    exit
fi

# Remove 'space', so filenames with spaces work well.
IFS="`$Printf '\n\t'`"

# Take all filenames and write in name.txt
$Ls -1 > .name.txt
FILE=.name.txt

# Create text info dialog with filenames.
# Here you can edit the filenames.
# And save as name.txt.edit
  $Zenity --text-info --editable \
           --width $WINDOW_WIDTH --height $WINDOW_HEIGHT \
           --title="$WINDOW_TITLE" \
           --filename=$FILE > $FILE.edit
                          
# Create a question dialog if you want rename the files.
  $Zenity --question --width $WINDOW_WIDTH --title="$WINDOW_TITLE" \
  --text="Do you want to rename the files?"

# Start rename the files.
if [[ $? == 0 ]] ; then
a=1
for i in `$Ls`
do
Line=$($Sed -ne "$a p" $FILE.edit)  
echo $Line
$Mv -n $i $Line
a=$[$a + 1]

done
else

# If user abort stop everything remove all files
# created by the script and then exit.
$Rm -rf .name.txt $FILE.edit
exit
fi

# Remove all files created by the script
$Rm -rf .name.txt $FILE.edit

# Notify when all finish and then exit.
$Notify "$WINDOW_TITLE" \
            "All files renamed."

exit 
