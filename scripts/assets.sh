#!/bin/bash

set -e

DOTFILES_DATA_DIR="${HOME}/.dotfiles/data"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

echo "==> Copying assets to $XDG_DATA_HOME..."
mkdir -p "$XDG_DATA_HOME"
cp -R "$DOTFILES_DATA_DIR/assets" "$XDG_DATA_HOME/"

echo "==> Assets copied successfully."
