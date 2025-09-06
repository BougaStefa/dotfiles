#!/bin/bash

art='
                                                                           
▀███▀▀▀██▄   ▄▄█▀▀██▄ ███▀▀██▀▀██████▀▀▀███████▀████▀   ▀███▀▀▀███ ▄█▀▀▀█▄█
  ██    ▀██▄██▀    ▀██▄▀   ██   ▀█ ██    ▀█ ██   ██       ██    ▀█▄██    ▀█
  ██     ▀███▀      ▀██    ██      ██   █   ██   ██       ██   █  ▀███▄    
  ██      ███        ██    ▓█      ██▀▀██   ██   ██       ██████    ▀█████▄
  █▓     ▄███        ██    ▓█      ▓█   █   █▓   █▓     ▄ ██   █  ▄     ▀██
  █▓    ▄█▓▀██      ██▀    ▓█      ▓█       █▓   █▓    ▒█ █▓     ▄██     ██
  ▓▓     ▓▓▓██      ▓█▓    ▓█      ▓▓       ▓▓   ▓▓     ▓ ▓▓   ▓  ▓     ▀█▓
  ▓▒    ▓▓▒▀█▓▓▓    ▓▓▓    ▓▓      ▒▓       ▒▓   ▓▒    ▓▓ ▓▓     ▓▓▓     ▓▓
▒ ▒ ▒ ▒ ▒    ▒ ▒ ▒ ▒     ▒ ▒▓▒▒  ▒▓▒ ▒    ▒▓▒ ▒▒ ▒▒ ▓▒ ▒▒ ▒▒▒▓▒ ▒ ▒▓▒ ▒ ▒▓ 
                                                                           
                                                                           
'

# Check for internet connectivity
if ! ping -c 1 archlinux.org &>/dev/null; then
  echo "No internet connection detected. Please connect and retry."
  exit 1
fi

# Install git if missing
if ! command -v git &>/dev/null; then
  echo "Installing git..."
  sudo pacman -Sy --noconfirm --needed git
fi

DOTFILES_REPO="BougaStefa/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

# Clone dotfiles repo if not present
if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "Cloning dotfiles from: https://github.com/${DOTFILES_REPO}.git"
  git clone "https://github.com/${DOTFILES_REPO}.git" "$DOTFILES_DIR"
fi

clear
echo -e "\n$art\n"

echo -e "\nInstalling..."
if [[ -f "$DOTFILES_DIR/install.sh" ]]; then
  source "$DOTFILES_DIR/install.sh"
else
  echo "install.sh not found in $DOTFILES_DIR"
  exit 1
fi

