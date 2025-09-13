#!/bin/bash

set -e

CONFIG_SRC="${HOME}/.dotfiles/config"
CONFIG_DEST="${HOME}/.config"

echo "==> Copying config files from $CONFIG_SRC to $CONFIG_DEST..."
mkdir -p "$CONFIG_DEST"
cp -R "$CONFIG_SRC/"* "$CONFIG_DEST/"

echo "==> Config files copied successfully."

echo "==> Symlinking xprofile and zprofile to home directory..."
ln -sf "$CONFIG_DEST/x11/xprofile" "$HOME/.xprofile"
ln -sf "$CONFIG_DEST/shell/profile" "$HOME/.zprofile"

echo "==> Setting Zsh as the default shell for $USER..."
chsh -s /bin/zsh "$name" >/dev/null 2>&1

echo "==> Creating Zsh cache directory..."
sudo -u "$USER" mkdir -p "/home/$USER/.cache/zsh/"

echo "==> Symlinks created."
