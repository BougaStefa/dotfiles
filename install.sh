#!/bin/bash

set -eE

DOTFILES_SCRIPTS_DIR="$HOME/.dotfiles/scripts"
DOTFILES_DATA_DIR="$HOME/.dotfiles/data"

source "$DOTFILES_SCRIPTS_DIR/preinstall.sh"

echo "==> Granting temporary passwordless sudo to wheel group..."
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/setup-temp >/dev/null
trap 'sudo rm -f /etc/sudoers.d/setup-temp' EXIT


catch_errors() {
  echo -e "\n\e[31mInstallation failed!\e[0m"
  echo "Retry by running ~/.dotfiles/install.sh"
}

trap catch_errors ERR

echo "==> Running system prep script..."
source "$DOTFILES_SCRIPTS_DIR/prep.sh"

echo "==> Setting up AUR helper..."
source "$DOTFILES_SCRIPTS_DIR/aur.sh"

echo "==> Installing packages..."
if [[ -n "$CATEGORY" ]]; then
  source "$DOTFILES_SCRIPTS_DIR/packages.sh" "$CATEGORY"
else
  source "$DOTFILES_SCRIPTS_DIR/packages.sh"
fi

echo "==> Running config setup..."
source "$DOTFILES_SCRIPTS_DIR/config.sh"

# Testing out tranfserring the plugins within the config
#echo "==> Setting up tmux plugins..."
#bash "$DOTFILES_SCRIPTS_DIR/tmux.sh"

echo "==> Configuring git..."
source "$DOTFILES_SCRIPTS_DIR/git.sh"

echo "==> Setting up Docker..."
source "$DOTFILES_SCRIPTS_DIR/docker.sh"

echo "==> Setting up network services..."
source "$DOTFILES_SCRIPTS_DIR/network.sh"

echo "==> Setting up Bluetooth..."
source "$DOTFILES_SCRIPTS_DIR/bluetooth.sh"

echo "==> Applying hardware tweaks..."
source "$DOTFILES_SCRIPTS_DIR/hardware.sh"


echo "==> Installing Suckless programs..."
source "$DOTFILES_SCRIPTS_DIR/suckless.sh"

echo "==> Install script complete."

source "$DOTFILES_SCRIPTS_DIR/reboot.sh"

