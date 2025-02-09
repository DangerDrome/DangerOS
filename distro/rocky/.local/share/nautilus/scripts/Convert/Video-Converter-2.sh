#!/bin/bash

#       video_converter.sh
#       
#       Copyright 2010 Harish.k <harish@ashwin-desktop>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
# This script is based on the idea from "http://stackoverflow.com/questions/2896670/a-reliable-way-to-get-the-progress-of-an-ffmpeg-conversion-in-bash"
# Thanks to Prupert

set -x
IFS=$(echo -en "\n\b")
bashfilepath=$(echo $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS |sed -e "s/ /\\\ /g")
fullname=$(basename $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS)



ffmpeglog=$fullname.nautilus_debug_test

#exec 6>&1
#exec 7>&1

format=$(zenity  --list  --text "Select libX264 Preset" --radiolist  --column "Pick" --column "Opinion" \
   FALSE "avi" \
   TRUE "mp4" \
   FALSE "Fix_Errors" \
)

filename=${fullname%.*}
origext=${fullname##*.}
if [ -z $origext -o  "$filename" == "$origext" ];then
   origext=$(ffmpeg -i $fullname  2>&1 | sed -n "s/.*Input\ \#0, \([^,]*\), from .*/\1/p")
fi

if [ "$format" != "Fix_Errors" ]; then
   preset=$(zenity  --list  --text "Select libX264 Preset" --radiolist  --column "Pick" --column "Opinion" \
      FALSE "lossless_slow" \
      FALSE "lossless_slower" \
      FALSE "lossless_medium" \
      FALSE "lossless_fast" \
      TRUE "lossless_ultrafast" \
      FALSE "lossless_max" \
      FALSE "max" \
      FALSE "hq" \
   )
fi
duration=( $(ffmpeg -i "$fullname" 2>&1 | sed -n "s/.* Duration: \([^,]*\), start: .*/\1/p") )
#echo $duration
fps=( $(ffmpeg -i "$fullname" 2>&1 | sed -n "s/.*, \(.*\) tbr.*/\1/p") )
#echo $fps
hours=( $(echo $duration | cut -d":" -f1) )
#echo $hours
minutes=( $(echo $duration | cut -d":" -f2) )
#echo $minutes
seconds=( $(echo $duration | cut -d":" -f3) )
#echo $seconds
# Get the integer part with cut
frames=( $(echo "($hours*3600+$minutes*60+$seconds)*$fps" | bc | cut -d"." -f1) )
if [ -z $frames ]; then
   zenity --info --title "$WindowTitle" --text "Can't calculate frames, sorry."
   exit
fi





is_integer() {
   s=$(echo $1 | tr -d 0-9)
   if [ -z "$s" ]; then
      return 0
   else
      return 1
   fi
   
}


progress() {
   #sleep 10
   ffmpeglog1=$ffmpeglog._1
   #some shenanigans due to the way ffmpeg uses carriage returns
   cat -v $ffmpeglog | tr '^M' '\n' > $ffmpeglog1
   #calculate percentage progress based on frames
   cframe=( $(tac $ffmpeglog1 | grep -m 1 frame= | awk '{print $2}' | cut -c 7-) )
   #echo $cframe
   if [ -z $cframe ]; then
      cframe=( $(tac $ffmpeglog1 | grep -m 1 frame= | awk '{print $2}') )
      #echo $cframe
   fi
   if is_integer $frame; then
      percent=$((100 * cframe / frames))
      #if [ $percent = "100" ]; then
      #return 0
      #fi
      #calculate time left and taken etc
      fps=( $(tac $ffmpeglog1 | grep -m 1 frame= | awk '{print $3}') )
      #echo $fps
      if [ "$fps" = "fps=" ]; then
         fps=( $(tac $ffmpeglog1 | grep -m 1 frame= | awk '{print $4}') )
         if [ "$fps" = "0" ]; then
            fps=100
         fi
         echo $fps
      fi
      total=$(( frames + cframe + percent + fps ))
      
      #simple check to ensure all values are numbers
      if is_integer $total; then
         #all ok continue
         if [ -z $fps ]; then
            #echo -ne "\r testffmpeg: $cframe of $frames frames, progress: $percent"%" and ETA: error fps:0"
            zenity  --warning --title "Error"   --text "Please read debug log"
            percent=100
         else
            if [ -z $cframe ]; then
               echo -ne "\rffmpeg: total $frames frames, error cframes:0"
            else
               remaining=$(( frames - cframe ))
               seconds=$(( remaining / fps ))
               h=$(( seconds / 3600 ))
               m=$(( ( seconds / 60 ) % 60 ))
               s=$(( seconds % 60 ))
             
               echo $percent
               echo "# Remaining $seconds seconds"
            fi
         fi
      else
         echo "Error, one of the values wasn't a number, trying again in 10s."
      fi
   else
      echo "Error, frames is 0, progress wont work, sorry."
      
   fi
}

progshow () {
   while [ "$percent" != "100" ] ; do
      sleep 1
      progress
   done
   rm $ffmpeglog1
   rm $ffmpeglog
}
if [ "$format" = "Fix_Errors" ]; then
   ffmpeg -i $fullname -y -vcodec copy -acodec copy -sn -threads 4 "Error_Fixed.$filename.$origext" 2>$ffmpeglog &
   ffmpegpid=$!
else
   ffmpeg -i $fullname -y -vcodec libx264  -vpre $preset -sn -crf 25 -threads 4 "$filename"."$format" 2>$ffmpeglog &
   ffmpegpid=$!
fi
progshow|zenity --progress \
--title="Converting" \
--text="Calculatig Remainig time..." \
--percentage=0 \


if [ "$?" = 1 ] ; then
   zenity --question \
   --text="Realy cancel encoding?"
   if [ "$?" = 0 ] ; then
      kill $ffmpegpid
      
   fi
fi



