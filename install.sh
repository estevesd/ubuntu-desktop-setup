#!/bin/bash

MYUSER=$USER

sudo su -

add-apt-repository -yn ppa:apt-fast/stable
add-apt-repository -yn ppa:bashtop-monitor/bashtop
apt update
apt install -y  apt-fast \
    bashtop \
    gettext
    git \
    gnome-shell-extensions \
    gnome-tweaks \
    make \
    preload \
    ssh \
    terminator \
    vim

# install Nordic theme
## Global theme
mkdir ~/.themes
wget https://github.com/EliverLara/Nordic/releases/download/v2.1.0/Nordic-darker.tar.xz -o /tmp/Nordic-darker.tar.xz
tar -xf /tmp/Nordic-darker.tar.xz -C ~/.themes
rm /tmp/Nordic-darker.tar.xz
gsettings set org.gnome.desktop.interface gtk-theme "Nordic-darker"
gsettings set org.gnome.desktop.wm.preferences theme "Nordic-darker"

## cursors
git clone --depth 1 --branch master --single-branch https://github.com/EliverLara/Nordic /tmp/Nordic
mkdir -p ~/.icons/Nordic
cp -R /tmp/Nordic/kde/cursors/Nordic-cursors/* ~/.icons/Nordic
gsettings set org.gnome.desktop.interface cursor-theme "Nordic"

## Wallpaper
cp fs/usr/share/backgrounds/* /usr/share/backgrounds
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/nordic-wall.jpg
gsettings set org.gnome.desktop.screensaver picture-uri file:///usr/share/backgrounds/nordic-wall.jpg

## Icons
sudo add-apt-repository ppa:papirus/papirus
sudo apt-get update
sudo apt-get install -y papirus-icon-theme papirus-folders
gsettings set org.gnome.desktop.interface icon-theme "Papyrus-Dark"
papirus-folders -C nordic -- theme Papirus-Dark

# Gnome extensions
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com

## install
### dash-to-panel
wget https://github.com/home-sweet-gnome/dash-to-panel/releases/download/v42/dash-to-panel@jderose9.github.com_v42.zip -O /tmp/dash-to-panel@jderose9.github.com_v42.zip
unzip /tmp/dash-to-panel@jderose9.github.com_v42.zip -d /tmp/dash-to-panel@jderose9.github.com
mkdir -p ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com
cp -R /tmp/dash-to-panel@jderose9.github.com/* ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com
### Latency monitor
git clone  --depth 1 --branch master --single-branch https://gitlab.com/walkafwalka/gnome-shell-extension-latency-monitor.git /tmp/latency-monitor
cp -R /tmp/latency-monitor ~/.local/share/gnome-shell/extensions/latency-monitor@gitlab.labsatho.me
### sytem-mopnitor
apt install gir1.2-gtop-2.0 gir1.2-nm-1.0 gir1.2-clutter-1.0 gnome-system-monitor
git clone --depth 1 --branch master --single-branch https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet /tmp/system-monitor
cd /tmp/system-monitor
make install
## restart gnome
busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")'

##restore exntensions settings
dconf load /org/gnome/shell/extensions/ < dconf/extensions-settings.dconf

## enable extensions
gnome-extensions enable dash-to-panel@jderose9.github.com
gnome-extensions enable latency-monitor@gitlab.labsatho.me

# Snaps
snap install 1password drawio postman spotify vlc
snap install code --classic
snap install slack --classic
snap install sublime-merge --classic

# system conf
mkdir -p "/home/${MYUSER}/Pictures/#Screenshots"
gsettings set org.gnome.gnome-screenshot auto-save-directory "/home/${MYUSER}/Pictures/#Screenshots"
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
gsettings set org.gnome.system.locale region 'en_CA.UTF-8'
gsettings set org.gnome.desktop.input-sources xkb-options "['altwin:ctrl_alt_win', 'shift:breaks_caps', 'compose:caps']"

# Apps conf
cp -R .config/* /home/${MYUSER}/.config

# Optimisations
gsettings set org.gnome.desktop.interface enable-animations false
echo 'Acquire::Languages "none";' | sudo tee -a /etc/apt/apt.conf.d/00aptitude
