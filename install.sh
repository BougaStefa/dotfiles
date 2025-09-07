#!/bin/bash

set -eE

echo "==> Granting temporary passwordless sudo to wheel group..."
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/setup-temp >/dev/null
trap 'sudo rm -f /etc/sudoers.d/setup-temp' EXIT

DOTFILES_SCRIPTS_DIR="$HOME/.dotfiles/scripts"
DOTFILES_DATA_DIR="$HOME/.dotfiles/data"

catch_errors() {
  echo -e "\n\e[31mInstallation failed!\e[0m"
  echo "Retry by running ~/.dotfiles/install.sh"
}

trap catch_errors ERR

# Set CATEGORY from argument, if provided
CATEGORY="${1:-}"

echo "==> Running system prep script..."
bash "$DOTFILES_DATA_DIR/setup-system.sh"

echo "==> Setting up AUR helper..."
bash "$DOTFILES_SCRIPTS_DIR/aur.sh"

echo "==> Installing packages..."
if [[ -n "$CATEGORY" ]]; then
  bash "$DOTFILES_SCRIPTS_DIR/packages.sh" "$CATEGORY"
else
  bash "$DOTFILES_SCRIPTS_DIR/packages.sh"
fi
echo "==> Install script complete."

