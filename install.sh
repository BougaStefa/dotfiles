#!/bin/bash

set -eE

DOTFILES_SCRIPTS_DIR="$HOME/.dotfiles/scripts"

catch_errors() {
  echo -e "\n\e[31mInstallation failed!\e[0m"
  echo "Retry by running ~/.dotfiles/install.sh"
}

trap catch_errors ERR

# Set CATEGORY from argument, if provided
CATEGORY="${1:-}"

# Set up AUR helper
source "$DOTFILES_SCRIPTS_DIR/aur.sh"

# Install packages (pass category if set)
if [[ -n "$CATEGORY" ]]; then
  bash "$DOTFILES_SCRIPTS_DIR/packages.sh" "$CATEGORY"
else
  bash "$DOTFILES_SCRIPTS_DIR/packages.sh"
fi

