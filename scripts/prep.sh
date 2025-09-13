#!/bin/bash

set -eEu

echo "==> Installing essential packages: base-devel, reflector..."
sudo pacman -Sy --needed --noconfirm base-devel reflector

echo "==> Updating Arch Linux mirrorlist with reflector..."
sudo reflector --country 'United Kingdom,Germany' --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo "==> Showing top mirrors:"
head -20 /etc/pacman.d/mirrorlist

echo "==> Copying custom pacman.conf to /etc/pacman.conf..."
sudo cp -f "$HOME/.dotfiles/data/pacman.conf" /etc/pacman.conf

echo "==> System setup complete."

