#!/bin/bash

if [ $(id -u) = 0 ]; then
   echo "This script changes your users gsettings and should thus not be run as root!"
   echo "You may need to enter your password multiple times!"
   exit 1
fi

DNF="dnf -y "
VERSION=35

echo "Enabling RPM Fusion"
sudo $DNF install  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo $DNF upgrade --refresh
sudo $DNF groupupdate  core
sudo $DNF install  rpmfusion-free-release-tainted
sudo $DNF install  dnf-plugins-core

echo "Enabling Better Fonts by Dawid"
sudo -s $DNF  copr enable dawid/better_fonts
sudo -s $DNF install  fontconfig-font-replacements
sudo -s $DNF install  fontconfig-enhanced-defaults

echo "Speeding Up DNF"
echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
notify-send "Your DNF config has now been amended" --expire-time=10

echo "Install flatpak"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update

echo "Install updates"
sudo $DNF upgrade --refresh
sudo $DNF check
sudo $DNF autoremove
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

echo "Installing Software"
sudo $DNF install  gnome-extensions-app gnome-tweaks gnome-shell-extension-appindicator vlc flatseal htop bleachbit git dnfdragora rdesktop audacious mscore-fonts-all neofetch cmatrix p7zip unzip gparted

echo "Installing Appearance Tweaks - Flat GTK and Icon Theme"
sudo $DNF install  gnome-shell-extension-user-theme paper-icon-theme flat-remix-icon-theme flat-remix-theme
gnome-extensions install user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Blue"
gsettings set org.gnome.desktop.wm.preferences theme "Flat-Remix-Blue"
gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue'

echo "Installing Tweaks, extensions & plugins"
sudo $DNF groupupdate  sound-and-video
sudo $DNF install  libdvdcss
sudo $DNF install  gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
sudo $DNF install  lame\* --exclude=lame-devel
sudo $DNF group upgrade  --with-optional Multimedia

echo "Installing microsoft edge"
sudo rpm -v --import https://packages.microsoft.com/keys/microsoft.asc
sudo $DNF config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
sudo mv /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo /etc/yum.repos.d/microsoft-edge.repo
sudo $DNF install  microsoft-edge-stable

echo "Installing snap"
sudo $DNF install  snapd
sudo systemctl enable snapd --now
sudo ln -s /var/lib/snapd/snap /snap

echo "Installing Codecs"
sudo $DNF groupupdate sound-and-video
sudo $DNF install  libdvdcss
sudo $DNF install  gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
sudo $DNF install  lame\* --exclude=lame-devel
sudo $DNF group upgrade --with-optional Multimedia
sudo $DNF config-manager --set-enabled fedora-cisco-openh264
sudo $DNF install  gstreamer1-plugin-openh264 mozilla-openh264

sudo $DNF config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo $DNF install brave-browser

sudo $DNF install dnf-utils
sudo $DNF config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
sudo $DNF install vivaldi-stable

sudo tee /etc/yum.repos.d/AnyDesk-Fedora.repo <<EOF
[anydesk]
name=AnyDesk Fedora - stable
baseurl=http://rpm.anydesk.com/fedora/x86_64/
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
EOF
sudo $DNF --releasever=$VERSION install pangox-compat.x86_64
sudo $DNF makecache
sudo $DNF install redhat-lsb-core anydesk

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat <<EOF | sudo tee /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
$DNF check-update
sudo $DNF install code

sudo $DNF  install wget
wget https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm
sudo $DNF  install ./teamviewer.x86_64.rpm
rm -f ./teamviewer.x86_64.rpm

sudo bash -c 'cat << EOF > /etc/yum.repos.d/atom.repo
[Atom]
name=Atom Editor
baseurl=https://packagecloud.io/AtomEditor/atom/el/7/x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=1
gpgkey=https://packagecloud.io/AtomEditor/atom/gpgkey
EOF'
sudo rpm --import https://packagecloud.io/AtomEditor/atom/gpgkey
sudo $DNF update
sudo $DNF install atom

sudo snap install pycharm-community --classic
sudo snap install intellij-idea-community --classic

flatpak install flathub com.spotify.Client

sudo $DNF copr enable kwizart/fedy
sudo $DNF install fedy

sudo $DNF install tlp tlp-rdw
sudo systemctl enable tlp

sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

sudo $DNF install gnome-shell-extension-dash-to-dock
sudo $DNF install gnome-shell-extension-appindicator
sudo $DNF install gnome-shell-extension-gsconnect.x86_64

sudo $DNF group install "Development Tools"

sudo $DNF  install bridge-utils libvirt virt-install qemu-kvm
sudo $DNF install libvirt-devel virt-top libguestfs-tools guestfs-tools
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo $DNF  install virt-manager

sudo $DNF  install dnf-plugins-core
sudo $DNF config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/$VERSION/winehq.repo
sudo $DNF  install winehq-stable
wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
sudo mv winetricks /usr/local/bin/

sudo $DNF install lm_sensors 

#echo "Doing DNF cleanup"
#sudo $DNF clean all

wget "https://sl.diltech.com/fedora_readme" -O ./readme.txt
echo "Read ./readme.txt for manual steps"
exit 0
