#!/bin/bash
#
# fonts.sh

CWD=$(pwd)

echo "[>] Installing FontForge"
dnf install -y fontforge > /dev/null
rm -rf /usr/share/fonts/microsoft
echo "[>] Downloading Microsoft fonts"
wget -c https://ponce.cc/slackware/sources/repo/webcore-fonts-3.0.tar.gz \
  > /dev/null 2>&1
echo "[>] Downloading Symbol font"
wget -c https://ponce.cc/slackware/sources/repo/symbol.gz > /dev/null 2>&1
mkdir /usr/share/fonts/microsoft
echo "[>] Uncompressing fonts archive"
tar -xzf ${CWD}/webcore-fonts-3.0.tar.gz
cd webcore-fonts
echo "[>] Generating Cambria TrueType fonts"
fontforge -lang=ff -c 'Open("vista/CAMBRIA.TTC(Cambria)"); \
  Generate("vista/CAMBRIA.TTF");Close();Open("vista/CAMBRIA.TTC(Cambria Math)"); \
  Generate("vista/CAMBRIA-MATH.TTF");Close();' > /dev/null 2>&1
rm vista/CAMBRIA.TTC
echo "[>] Installing fonts"
cp fonts/* /usr/share/fonts/microsoft/
cp vista/* /usr/share/fonts/microsoft/
echo "[>] Installing patched Symbol font"
gunzip -c ${CWD}/symbol.gz > /usr/share/fonts/microsoft/symbol.ttf
echo "[>] Updating fonts cache"
fc-cache -f -v > /dev/null 2>&1

exit 0
