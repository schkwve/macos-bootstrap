#!/bin/bash

## Colors
red="\e[1;31m"
green="\e[1;32m"
blue="\e[1;34m"
reset="\e[1;0m"

## Functions
install_cask() {
	printf "Installing $1..."
	brew install --cask $1 >/dev/null || exit 1
}

install_pkg() {
	printf "Installing $1..."
	brew install $1 >/dev/null || exit 1
}

# Check if we're actually running under macOS
uname=$(uname -s)
if [ $uname != "Darwin" ]; then
	printf "${red}[!]${reset} This script is supported only on macOS.\n"
	exit 1
fi

# Check for XCode Command Line Tools
xcode-select -p >/dev/null 2>&1
if [ $? -eq 0 ]; then
	printf "XCode Command Line Tools are already installed, skipping...\n"
else
	printf "Installing XCode Command Line Tools...\n"
	xcode-select --install >/dev/null || exit 1
fi

# Check if brew is installed
if [ -x "$(command -v brew)" ]; then
	printf "Brew is already installed, skipping...\n"
else
	printf "Installing brew...\n"
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh >/dev/null || exit 1
fi

# Update brew
printf "Running brew update...\n"
brew update >/dev/null

# Install basic packages
install_cask firefox
install_cask betterdiscord-installer
install_cask vlc
install_cask lulu
install_pkg neovim
install_pkg alacritty
install_pkg gotop
install_pkg neofetch

# Install BetterDiscord
printf "Running BetterDiscord Installer...\n"
xattr -d com.apple.quarantine /Applications/BetterDiscord.app >/dev/null 2>&1
open /Applications/BetterDiscord.app

# BetterDiscord plugins and themes
echo "Downloading BetterDiscord plugins and themes..."
wget -i discord-plugins.txt -P "${HOME}/Library/Application Support/BetterDiscord/plugins" >/dev/null 2>&1 || exit 1
wget -i discord-themes.txt -P "${HOME}/Library/Application Support/BetterDiscord/themes" >/dev/null 2>&1 || exit 1
mv ${HOME}/Library/Application\ Support/BetterDiscord/themes/style.css ${HOME}/Library/Application\ Support/BetterDiscord/themes/Black\ Hole.theme.css

# Copy config dotfiles
printf "Copying configuration files...\n"
touch ${HOME}/.hushlogin
cp -r dots/. ${HOME}/

# Set sensible defaults
chmod +x set-defaults.sh
./set-defaults.sh  >/dev/null 2>&1

# Kill affected applications
for app in "Activity Monitor" \
	"Address Book" \
	"Calendar" \
	"cfprefsd" \
	"Contacts" \
	"Dock" \
	"Finder" \
	"Mail" \
	"Messages" \
	"Photos" \
	"Safari" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done

# Notify the user of Firefox extensions and themes
printf "All done!\n"
printf "To finish the install, see the post-install notes in the README."