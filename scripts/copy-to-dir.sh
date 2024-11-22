#! /bin/bash
location=`zenity --file-selection --directory --title="Select a directory"`
for arg
do
if [ -e "$location"/"$arg" ];then
   zenity --question --title="Conflict While Copying" --text="File ""$location"/"$arg"" already exists. Would you like to replace it?"
   case "$?" in
      1  )  exit 1 ;;
      0  )  cp "$arg" "$location" ;;
   esac
else
   cp "$arg" "$location"
fi
done
   zenity --info --text "Finished Copying Files"
