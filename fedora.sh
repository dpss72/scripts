#!/bin/bash

if [ $(id -u) = 0 ]; then
   echo "This script changes your users gsettings and should thus not be run as root!"
   echo "You may need to enter your password multiple times!"
   exit 1
fi

echo "Enabling RPM Fusion"
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf upgrade --refresh
sudo dnf groupupdate -y core
sudo dnf install -y rpmfusion-free-release-tainted
sudo dnf install -y dnf-plugins-core

echo "Enabling Better Fonts by Dawid"
sudo -s dnf -y copr enable dawid/better_fonts
sudo -s dnf install -y fontconfig-font-replacements
sudo -s dnf install -y fontconfig-enhanced-defaults

echo "Speeding Up DNF"
echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
notify-send "Your DNF config has now been amended" --expire-time=10

echo "Install flatpak"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update

echo "Install updates"
sudo dnf upgrade --refresh
sudo dnf check
sudo dnf autoremove
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

echo "Installing Software"
sudo dnf install -y gnome-extensions-app gnome-tweaks gnome-shell-extension-appindicator vlc flatseal dnfdragora audacious mscore-fonts-all neofetch cmatrix p7zip unzip gparted

echo "Installing Appearance Tweaks - Flat GTK and Icon Theme"
sudo dnf install -y gnome-shell-extension-user-theme paper-icon-theme flat-remix-icon-theme flat-remix-theme
gnome-extensions install user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Blue"
gsettings set org.gnome.desktop.wm.preferences theme "Flat-Remix-Blue"
gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue'

echo "Installing Tweaks, extensions & plugins"
sudo dnf groupupdate -y sound-and-video
sudo dnf install -y libdvdcss
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade -y --with-optional Multimedia

echo "Installing microsoft edge"
sudo rpm -v --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
sudo mv /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo /etc/yum.repos.d/microsoft-edge.repo
sudo dnf install -y microsoft-edge-stable

echo "Installing snap"
sudo dnf install -y snapd
sudo ln -s /var/lib/snapd/snap /snap

echo "Installing Codecs"
sudo dnf groupupdate sound-and-video
sudo dnf install -y libdvdcss
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg 
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia
sudo dnf config-manager --set-enabled fedora-cisco-openh264
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264

echo "Doing DNF cleanup"
sudo dnf clean all

wget "https://sl.diltech.com/fedora_readme" -O ./readme.txt
echo "Read ./readme.txt for manual steps"
exit 0
