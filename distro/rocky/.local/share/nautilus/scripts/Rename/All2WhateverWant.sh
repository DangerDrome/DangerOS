#!/bin/sh
##
## SCRIPT: 00_multiRename_selFiles_addPrefix.sh
##
## PURPOSE: Adds a user-specified prefix to the names of the user-selected files.
##
##          Uses zenity to prompt for the prefix.
##
## NOTE: If you accidentally rename the wrong file(s), you can simply
##       rename it/them back, by removing the prefix.
##
## Created: 2010may19
## Changed: 

## FOR TESTING:
# set -v
# set -x

   FILENAMES="$@"
#  FILENAMES="$NAUTILUS_SCRIPT_SELECTED_URIS"

##
## Prompt for the prefix for the filenames. 
##

    FILEPREFIX=""
    FILEPREFIX=$(zenity --entry \
         --title "Enter PREFIX to add to filenames." \
         --text "\
Enter a prefix for the new filenames of the selected files. Examples:
      Vacation2010may_  OR  Kevin-  OR  GrandCanyon_  OR Birthday2009_" \
        --entry-text "")

if test "$FILEPREFIX" = ""
then
   exit
fi

##
## START THE LOOP on the filenames.
##

for FILENAME in $FILENAMES
do

##
## Use 'convert' to make the resized jpg file.
##

   mv "$FILENAME" "${FILEPREFIX}$FILENAME"
   
done




