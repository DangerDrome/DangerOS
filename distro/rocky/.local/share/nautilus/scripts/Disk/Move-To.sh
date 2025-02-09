#!/bin/bash

###############################################################################
#
# AUTHOR:	Bruno Casella (brunocasella@gmail.com)
#
# 
# DESCRIPTION:	move a selected file or folder to a destiny folder
#				
#
# REQUIREMENTS:	Nautilus file manager
#		Gnome2
#		gdialog, which is usually included in the gnome-utils package
#
# INSTALLATION:	copy to the ~/.gnome2/nemo-scripts directory
#		
# USAGE:	Select the file or folder you would like to move, right click
#			and execute this script. Then select the destination folder.
#
# VERSION INFO:	0.1  
#
#
# LICENSE:	GNU GPL
#
###############################################################################

FILE=`echo -n $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS`

DESTINO=$(zenity --title $FILE --file-selection --directory)

#sed 's# #\ #g' $DESTINO

mv -u "$FILE" "$DESTINO"
exit


