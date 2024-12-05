#!/bin/bash
#
# menus.sh

CWD=$(pwd)

ENTRIESDIR="${CWD}/menus"

ENTRIES=$(ls ${ENTRIESDIR})

for ENTRY in ${ENTRIES}
do
  if [ -r /usr/share/applications/${ENTRY} ]
  then
    echo "Installing custom menu entry: ${ENTRY}"
    cat ${ENTRIESDIR}/${ENTRY} > /usr/share/applications/${ENTRY}
    sleep 0.5
  fi
done
echo "[>] Updating desktop database"
update-desktop-database
sleep 1
echo "[>] Custom desktop menu installed"
sleep 1

exit 0
