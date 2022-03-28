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
sudo dnf install -y gnome-extensions-app gnome-tweaks gnome-shell-extension-appindicator vlc flatseal htop bleachbit git dnfdragora rdesktop audacious mscore-fonts-all neofetch cmatrix p7zip unzip gparted

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
sudo systemctl enable snapd --now
sudo ln -s /var/lib/snapd/snap /snap

echo "Installing Codecs"
sudo dnf groupupdate sound-and-video
sudo dnf install -y libdvdcss
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg 
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia
sudo dnf config-manager --set-enabled fedora-cisco-openh264
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264

sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser

sudo dnf install dnf-utils
sudo dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
sudo dnf install vivaldi-stable

sudo tee /etc/yum.repos.d/AnyDesk-Fedora.repo <<EOF
[anydesk]
name=AnyDesk Fedora - stable
baseurl=http://rpm.anydesk.com/fedora/x86_64/
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
EOF
sudo dnf --releasever=32 install pangox-compat.x86_64
sudo dnf makecache
sudo dnf install redhat-lsb-core anydesk

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat <<EOF | sudo tee /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
dnf check-update
sudo dnf install code

sudo dnf -y install wget
wget https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm
sudo dnf -y install ./teamviewer.x86_64.rpm
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
sudo dnf update
sudo dnf install atom

sudo snap install pycharm-community --classic
sudo snap install intellij-idea-community --classic

flatpak install flathub com.spotify.Client

sudo dnf copr enable kwizart/fedy
sudo dnf install fedy -y

sudo dnf install tlp tlp-rdw
sudo systemctl enable tlp

sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

sudo dnf install gnome-shell-extension-dash-to-dock
sudo dnf install gnome-shell-extension-appindicator
sudo dnf install gnome-shell-extension-gsconnect.x86_64

sudo dnf group install "Development Tools"

sudo dnf -y install bridge-utils libvirt virt-install qemu-kvm
sudo dnf install libvirt-devel virt-top libguestfs-tools guestfs-tools
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo dnf -y install virt-manager


echo "Doing DNF cleanup"
sudo dnf clean all

wget "https://sl.diltech.com/fedora_readme" -O ./readme.txt
echo "Read ./readme.txt for manual steps"
exit 0
