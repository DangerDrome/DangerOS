#!/bin/sh
##
## Nautilus
## SCRIPT: 00_oneProperties_movieFile_ffmpeg.sh
##
## PURPOSE: Shows the properties of a movie file ---
##          a 'flv' Flash movie file or 'wmv' or 'avi' or
##          or 'mpg' or 'mov' movie file or whatever.
##
##          Uses 'ffmpeg -i'.
##
##          Shows the text output in a text viewer, after
##          eliminating some distracting text.
##
## NOTE: This script has only been tested on 'flv' and 'mpg' files (to 2010aug06).
##       Need to test on 'wmv', 'avi', 'mov', or 'ogv' file formats.
##
## Started: 2010mar08
## Changed:

## FOR TESTING:
# set -v
# set -x

#########################################
## Get the filename of the selected file.
#########################################

  FILENAME="$1"
# FILENAMES="$@"
# FILENAMES="$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"

#########################################################################
## MIGHT BE BETTER TO COMMENT OUT THIS CHECK:
## Check that the selected file is a 'flv' or 'wmv' or 'avi' or
## 'mpg' file --- or some other movie file [suffix to be added to the test].
##
##     (Assumes just one dot [.] in the filename, at the extension.)
#########################################################################

  FILEEXT=`echo "$FILENAME" | cut -d\. -f2`
 
  if test "$FILEEXT" != "flv" -a "$FILEEXT" != "wmv" -a \
          "$FILEEXT" != "mpg" -a "$FILEEXT" != "ogv" -a \
          "$FILEEXT" != "avi" -a "$FILEEXT" != "mov"
  then
     exit
  fi


##################################
## Prepare the output filename(s).
##################################

   FILEOUT="/tmp/movie_properties_ffmpeg.txt"

   if test -f "$FILEOUT"
   then
      rm -f "$FILEOUT"
   fi

   FILEOUT2="/tmp/movie_properties_ffmpeg_2.txt"

   if test -f "$FILEOUT2"
   then
      rm -f "$FILEOUT2"
   fi


########################################################################
## Use 'ffmpeg' to put the properties of the movie file in a text file.
########################################################################

## FOR TESTING:
# xterm -hold -e \

#  ffmpeg -i "$FILENAME" 2> "$FILEOUT"

   ffmpeg -i "$FILENAME" 2> "$FILEOUT" >  "$FILEOUT2"

###############################
## Meaning of the ffmpeg parms:
##
## -i  val = input filename
###############################

echo "\
ffmpeg output:
#############
" > "$FILEOUT2"

#  tail -n +11 "$FILEOUT" | head -4 >>  "$FILEOUT2"
## IS REPLACED by the several lines below.

   LINE_BUILTON=`grep -n 'built on' "$FILEOUT" | cut -d: -f1`
   LINE_BUILTON=`expr $LINE_BUILTON + 1`

#  tail -n +$LINE_BUILTON "$FILEOUT" | head -4 >>  "$FILEOUT2"
   tail -n +$LINE_BUILTON "$FILEOUT" | grep -v 'output file must be specified' \
         >>  "$FILEOUT2"

###########################
## Show the output file.
###########################

. $HOME/.gnome2/nemo-scripts/.set_VIEWERvars.shi

$TXTVIEWER "$FILEOUT2" &

