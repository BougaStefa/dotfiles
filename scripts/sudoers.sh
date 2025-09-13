#!/bin/bash

set -e

echo "==> Granting passwordless sudo access to wheel group for all commands..."
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/00-wheel-nopasswd >/dev/null

echo "==> Setting Neovim as default visudo editor..."
echo "Defaults editor=/usr/bin/nvim" | sudo tee /etc/sudoers.d/01-visudo-editor >/dev/null
