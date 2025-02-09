#!/bin/sh
##
## Nautilus
## SCRIPT: 00_oneConvert_wavTOmp3.sh
##
## PURPOSE: To convert a '.wav' audio file to a '.mp3' audio file.
##          Uses 'ffmpeg'.
##          Play the new file in an audio player.
##
## Created: 2010mar08
## Changed: 

## FOR TESTING:
# set -v

##
## Get the filename of the selected file.
##

# FILENAMES="$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"
# FILENAMES="$@"
  FILENAME="$1"


##
## Check that the selected file is a 'wav' file.
##

  FILEEXT=`echo "$FILENAME" | cut -d\. -f2`
 
  if test "$FILEEXT" != "wav"
  then
     exit
  fi


##
## Use 'ffmpeg' to make the 'mp3' file --- high-quality.
##

   FILENAMECROP=`echo "$FILENAME" | sed 's|\.flv$||'`

   FILEOUT="${FILENAMECROP}.mp3"

   ffmpeg -i "$FILENAME" -ab 192k -ar 44100 -vn \
          -y "$FILEOUT"

## If necessary use '-acode' parm.

## Meaning of the parms:
##
## -i  val = input filename
## -ab val = audio bitrate in k?bits/sec (default = 64 kbps)
## -ar val = audio sampling frequency in Hz (default = 44100 Hz)
## -r  val = frame rate in frames/sec
## -b  val = video bitrate in kbits/sec (default = 200 kbps)
## -s  val = frame size, wxh where w and h are pixels or abbrevs:
##          qqvga =  160x120
##           qvga =  320x240
##            vga =  640x480
##           svga =  800x600
##            xga = 1024x768
##           sxga = 1280x1024
##           uxga = 1600x1200
##               
## Some other useful params:
## 
## Video:
##   -aspect (4:3, 16:9 or 1.3333, 1.7777)
##   -croptop pixels
##   -cropbottom pixels
##   -cropleft pixels
##   -cropright pixels
##   -padtop (bottom, left, right)
##   -padcolor <6 digit hex number>
##   -vn - disable video recording
##   -y  = overwrite output file(s)
##   -t duration - format is hh:mm:ss[.xxx]
##   -fs file-size-limit
##   -ss position - seek to given position, in secs or hh:mm:ss[.xxx]
##   -target type - where type is vcd or svcd or dvd or ..., then
##    bitrate, codecs, buffersizes are set automatically.
##   -vcodec codec - to force the video codec.
##                   Example: -vcodec mpeg4 
##                   Try  "ffmpeg -formats"
##   -pass n, where n is 1 or 2
##
## Audio:
##   -ac channels - default = 1
##   -an - disable audio recording
##   -acode codec - to force the audio codec. Example:
##                                      -acodec libmp3lame
## Other:
##   -debug
##   -threads count
##
##

##
## Play the new audio file.
##

# vlc      "$FILEOUT" &
  gmplayer "$FILEOUT" &


   
