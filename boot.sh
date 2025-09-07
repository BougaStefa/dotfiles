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

echo "==> Checking internet connectivity..."
if ! ping -c 1 archlinux.org &>/dev/null; then
  echo "No internet connection detected. Please connect and retry."
  exit 1
fi

echo "==> Ensuring git is installed..."
if ! command -v git &>/dev/null; then
  echo "==> Installing git..."
  sudo pacman -Sy --noconfirm --needed git
fi

DOTFILES_REPO="BougaStefa/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

echo "==> Checking for dotfiles repository..."
if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "==> Cloning dotfiles from: https://github.com/${DOTFILES_REPO}.git"
  git clone "https://github.com/${DOTFILES_REPO}.git" "$DOTFILES_DIR"
fi

clear
echo -e "\n$art\n"

echo "==> Running install script..."
if [[ -f "$DOTFILES_DIR/install.sh" ]]; then
  bash "$DOTFILES_DIR/install.sh"
else
  echo "install.sh not found in $DOTFILES_DIR"
  exit 1
fi

