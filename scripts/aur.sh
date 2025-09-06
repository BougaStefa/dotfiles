#!/bin/bash

if ! command -v yay &>/dev/null; then
  sudo pacman -Sy --needed --noconfirm base-devel git
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
  cd "$tmpdir/yay-bin"
  makepkg -si --noconfirm
  cd ~
  rm -rf "$tmpdir"
  echo "yay-bin installation complete."
fi
