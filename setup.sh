#!/bin/bash
# define functions that install packages
install_apt_packages() {
	# Define multi-line list of packages to install
	local packages=("htop" \
					"vlc" \
					"neofetch" \
					"vim" \
					"ffmpeg" \
					"most" \
					"ufw" \
					"fonts-powerline" \
					"thunderbird" \
					"keepassxc" \
					"ark" \
					"git" \
					"gnome-disk-utility" \ 
					"tlp" \
					"tlp-rdw" \
					"zsh"\
					"fonts-quicksand")
					
	# Loop through list and install each package with apt
	for package in "${packages[@]}"
	do
	    sudo nala install "$package" -y
	done
}

install_flatpak_packages() {
	# Define multi-line list of packages to install
	local packages=("md.obsidian.Obsidian" \
					"org.onlyoffice.desktopeditors" \
					"com.microsoft.Edge" \
					"nz.mega.MEGAsync" \
					"io.github.Qalculate" \
					"net.hovancik.Stretchly" \
					"org.cryptomator.Cryptomator" \
					"com.github.d4nj1.tlpui" # power management \
					"com.gitlab.newsflash" \ # RSS
					"org.mozilla.firefox")
	
	# Loop through list and install each package with apt
	for package in "${packages[@]}"
	do
	    sudo flatpak install flathub "$package" -y
	done
}

# update system
sudo apt-get update && sudo apt-get upgrade -y

# install package managers
sudo apt-get install nala
## install deb-get
sudo nala install curl
curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get

# install packages
install_apt_packages

# enable power-saving (laptops only)
sudo systemctl enable tlp.service

## Special programs: programs that require you go to some URL and download the package

### install syncthing stable version
sudo curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt update
sudo apt install syncthing

### install brave stable
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser

## oh my zsh installs. Ensure you set ZSH_THEME too
cd ~
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cd ~/Downloads
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# todo: add URL for my .zshrc file

## Add hosts file URLs
# List of GitHub raw file URLs
file_urls=(
  "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn/hosts"
)

cd ~

local_file="blocked_websites.txt"

# Make local file
touch $local_file

# Loop through each file URL and append its content to the local file
for url in "${file_urls[@]}"; do
  # Fetch the raw content from GitHub and append to the file
  curl -s file_urls >> $local_file
done

# Append everything in local_file to hosts
cat $local_file | sudo tee -a /etc/hosts

# Verify changes
#cat "$local_file"

# Refresh DNS cache (requires systemd)
sudo systemctl restart systemd-resolved

## flatpak installs

### install flatpak (reboot before installing flatpaks)
sudo nala install flatpak
### add flatpak repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# firewall hardening
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# create admin account. Must enter password
sudo useradd -m admin
sudo passwd admin
sudo adduser admin sudo

# create directory in documents for PKM
mkdir ~/Documents/Personal\ Knowledge\ System

# auto-install required drivers for Ubuntu. DOES NOT WORK WITH OTHER SYSTEMS.
sudo ubuntu-drivers autoinstall

# install dev-related stuff
sudo nala install pip

# reboots system. This is required to allow flatpaks to work
systemctl reboot

#####################################

# after reboot do the following commands

### install flatpaks
install_flatpak_packages
