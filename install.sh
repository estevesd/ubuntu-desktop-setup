#!/bin/bash

MYUSER=$USER
SCRIPT_PATH=$(pwd)
TMP=/tmp/ubuntu-desktop-setup
mkdir -p /tmp/ubuntu-desktop-setup

sudo add-apt-repository -yn ppa:apt-fast/stable
sudo add-apt-repository -yn ppa:bashtop-monitor/bashtop
sudo add-apt-repository -yn ppa:papirus/papirus
sudo apt update
sudo apt install -y  apt-fast \
    bashtop \
    dconf-editor \
    gettext \
    git \
    gnome-shell-extensions \
    gnome-tweaks \
    libglib2.0-dev-bin \
    make \
    preload \
    ssh \
    terminator \
    vim \
    xz-utils

cp -R ${SCRIPT_PATH}/home/* /home/${MYUSER}/
cp -R ${SCRIPT_PATH}/fs/* /

# Gnome extensions
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions disable desktop-icons@csoriano

# install Nordic theme
## Global theme
mkdir -p ~/.themes
wget https://github.com/EliverLara/Nordic/releases/download/v2.1.0/Nordic-darker.tar.xz
tar xJf ${TMP}/Nordic-darker.tar.xz -C ~/.themes
gsettings set org.gnome.desktop.interface gtk-theme "Nordic-darker"
gsettings set org.gnome.desktop.wm.preferences theme "Nordic-darker"

## cursors
git clone --depth 1 --branch master --single-branch https://github.com/EliverLara/Nordic ${TMP}/Nordic
mkdir -p ~/.icons/Nordic
cp -R ${TMP}/Nordic/kde/cursors/Nordic-cursors/* ~/.icons/Nordic
gsettings set org.gnome.desktop.interface cursor-theme "Nordic"

## Wallpaper
gsettings set org.gnome.desktop.background picture-uri "file:////home/${MYUSER}/Pictures/#backgrounds/nordic-wall.jpg"
gsettings set org.gnome.desktop.screensaver picture-uri "file:///home/${MYUSER}/Pictures/#backgrounds/nordic-wall.jpg"

## Icons
sudo apt-get install -y papirus-icon-theme papirus-folders
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
sudo papirus-folders -C nordic -t Papirus-Dark

# login
wget -qO - https://github.com/PRATAP-KUMAR/ubuntu-gdm-set-background/archive/main.tar.gz | tar zx --strip-components=1 ubuntu-gdm-set-background-main/ubuntu-gdm-set-background
chmod +x ubuntu-gdm-set-background
mv ubuntu-gdm-set-background /usr/sbin/gdm-set-background
sudo gdm-set-background --color \#233440

## install
### dash-to-panel
wget https://github.com/home-sweet-gnome/dash-to-panel/releases/download/v42/dash-to-panel@jderose9.github.com_v42.zip -O ${TMP}/dash-to-panel@jderose9.github.com_v42.zip
unzip ${TMP}/dash-to-panel@jderose9.github.com_v42.zip -d ${TMP}/dash-to-panel@jderose9.github.com
mkdir -p ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com
cp -R ${TMP}/dash-to-panel@jderose9.github.com/* ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com
### Latency monitor
git clone  --depth 1 --branch master --single-branch https://gitlab.com/walkafwalka/gnome-shell-extension-latency-monitor.git ${TMP}/latency-monitor
glib-compile-schemas ${TMP}/latency-monitor/schemas
rm -rf ${TMP}/latency-monitor/.git
cp -R ${TMP}/latency-monitor ~/.local/share/gnome-shell/extensions/latency-monitor@gitlab.labsatho.me
### system-mopnitor
sudo apt install -y gir1.2-gtop-2.0 gir1.2-nm-1.0 gir1.2-clutter-1.0 gnome-system-monitor
git clone --depth 1 --branch master --single-branch https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet ${TMP}/system-monitor
cd ${TMP}/system-monitor
make install
cd $SCRIPT_PATH

## restart gnome
./restart_gnome.sh

## enable extensions
gnome-extensions enable dash-to-panel@jderose9.github.com
gnome-extensions enable latency-monitor@gitlab.labsatho.me

##restore exntensions settings
dconf load /org/gnome/shell/extensions/ < ${SCRIPT_PATH}/dconf/extensions-settings.dconf

# Snaps
sudo snap install 1password drawio postman spotify vlc
sudo snap install code --classic
sudo snap install slack --classic
sudo snap install sublime-merge --classic

# system conf
mkdir -p "/home/${MYUSER}/Pictures/#Screenshots"
gsettings set org.gnome.gnome-screenshot auto-save-directory "/home/${MYUSER}/Pictures/#Screenshots"
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
gsettings set org.gnome.system.locale region 'en_CA.UTF-8'
gsettings set org.gnome.desktop.input-sources xkb-options "['altwin:ctrl_alt_win', 'shift:breaks_caps', 'compose:caps']"

# Optimisations
gsettings set org.gnome.desktop.interface enable-animations false
echo 'Acquire::Languages "none";' | sudo tee -a /etc/apt/apt.conf.d/00aptitude

rm -rf $TMP

while true; do
    read -p "Reboot now?" yn
    case $yn in
        [Yy]* ) reboot; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes(Y|y) or no(|Nn).";;
    esac
done


