#!/bin/bash

set -e

CONFIG_SRC="${HOME}/.dotfiles/config"
CONFIG_DEST="${HOME}/.config"

echo "==> Copying config files from $CONFIG_SRC to $CONFIG_DEST..."
mkdir -p "$CONFIG_DEST"
cp -R "$CONFIG_SRC/"* "$CONFIG_DEST/"

echo "==> Config files copied successfully."
