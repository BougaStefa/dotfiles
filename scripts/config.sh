#!/bin/bash

set -e

CONFIG_SRC="${HOME}/.dotfiles/config"
CONFIG_DEST="${HOME}/.config"

echo "==> Copying config files from $CONFIG_SRC to $CONFIG_DEST..."
mkdir -p "$CONFIG_DEST"
cp -R "$CONFIG_SRC/"* "$CONFIG_DEST/"

echo "==> Config files copied successfully."

echo "==> Symlinking xprofile, zprofile, and zshrc to home directory..."
ln -sf "$CONFIG_DEST/x11/xprofile" "$HOME/.xprofile"
ln -sf "$CONFIG_DEST/shell/profile" "$HOME/.zprofile"
ln -sf "$CONFIG_DEST/zsh/.zshrc" "$HOME/.zshrc"

echo "==> Setting Zsh as the default shell for $USER..."
sudo chsh -s /bin/zsh "$USER"

echo "==> Creating Zsh cache directory..."
sudo -u "$USER" mkdir -p "/home/$USER/.cache/zsh/"

echo "==> Symlinks created."

echo "==> Copying binaries to ~/.local/bin..."
mkdir -p "$HOME/.local/bin"
cp -R "${HOME}/.dotfiles/bin/"* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/"*

echo "==> Binaries and data files copied successfully."
