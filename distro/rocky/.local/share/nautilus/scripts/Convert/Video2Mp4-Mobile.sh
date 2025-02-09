!#/bin/bash


# SIVIA81 :
# GPL     :
# convert video in mp4 1.1 :

fails="$@"
size=$(zenity --title "convert video in mp4" --entry --text="" --entry-text "320x240")
ffmpeg -i "$@" -s "$size" "$fails".mp4 | (zenity --progress --pulsate --auto-close --title="convert" --text="$fails")

