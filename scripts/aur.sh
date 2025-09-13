#!/bin/bash

echo "==> Checking for yay (AUR helper)..."
if ! command -v yay &>/dev/null; then
  echo "==> Installing base-devel and git (required for yay)..."
  sudo pacman -Sy --needed --noconfirm base-devel git

  echo "==> Cloning yay-bin from AUR..."
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"

  echo "==> Building and installing yay..."
  cd "$tmpdir/yay-bin"
  makepkg -si --noconfirm

  cd ~
  rm -rf "$tmpdir"
  echo "==> yay-bin installation complete."
else
  echo "==> yay is already installed."
fi
