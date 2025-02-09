#!/bin/sh
##
## Nautilus
## SCRIPT: 00_oneExtractAudio_movieTOmp3_ffmpeg.sh
##
## PURPOSE: Extract the audio from a movie file ('.flv' Flash video file or
##          'wmv' or 'avi' or 'mov' ...) into a '.mp3' audio file.
##               Uses 'ffmpeg'.
##          Startup the new audio file in an audio editor, like audacity.
##                 (Could adjust volume there.)
##
## Started: 2010mar22
## Changed:

## FOR TESTING:
# set -v
# set -x

##
## Get the filename of the selected file.
##

# FILENAME="$@"
  FILENAME="$1"
# FILENAMES="$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"


##
## Check that the selected file is a 'flv' or 'wmv' or 'avi' file
## --- or some other movie file, suffix to be added.
##     (Assumes one '.' in the filename, at the extension.)

  FILEEXT=`echo "$FILENAME" | cut -d\. -f2`
 
  if test "$FILEEXT" != "flv" -a "$FILEEXT" != "wmv" -a \
          "$FILEEXT" != "avi" -a "$FILEEXT" != "mov"
  then
     exit
  fi


##
## Prepare the output 'mp3' filename.
##

   FILENAMECROP=`echo "$FILENAME" | cut -d\. -f1`

   FILEOUT="${FILENAMECROP}.mp3"

   if test -f "$FILEOUT"
   then
      rm -f "$FILEOUT"
   fi

##
## Use 'ffmpeg' to make the 'mp3' file.
##

   ffmpeg -i "$FILENAME" -vn -ab 128k -ar 44100 "$FILEOUT"

#  ffmpeg -i "$FILENAME" -vn -ab 128k -ar 44100 -acodec libmp3lame -ac 2 \
#         "$FILEOUT"

## An 'acodec copy' example 
## FROM: http://howto-pages.org/ffmpeg/#strip
## ffmpeg -i mandelbrot.flv -vn -acodec copy mandelbrot.mp3


## Meaning of some common ffmpeg parms:
##
## -i  val = input filename
## -ab val = audio bitrate in bits/sec (default = 64k)
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
## Audio:
##   -ac channels - default = 1
##   -acode codec - to force the audio codec. Example:
##                                      -acodec libmp3lame
##   -an - disable audio recording
##   -vn - disable video recording
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
## Other:
##   -debug
##   -threads count
##
##

##
## Play the new audio file.
##

   if test ! -f "$FILEOUT"
   then
      exit
   fi

# vlc      "$FILEOUT" &
# gmplayer "$FILEOUT" &
# /usr/bin/ffplay "$FILEOUT"
  audacity "$FILEOUT" &



   
