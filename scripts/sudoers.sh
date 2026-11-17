#!/bin/bash

set -e

# Validate each rule with visudo before installing it: a syntax error in
# /etc/sudoers.d breaks sudo for everyone.
install_sudoers_rule() {
  local name=$1 rule=$2 tmp
  tmp=$(mktemp)
  printf '%s\n' "$rule" >"$tmp"
  if sudo visudo -cqf "$tmp"; then
    sudo install -m 0440 -o root -g root "$tmp" "/etc/sudoers.d/$name"
  else
    echo "==> Invalid sudoers rule for $name, not installing." >&2
  fi
  rm -f "$tmp"
}

echo "==> Granting passwordless sudo access to wheel group for all commands..."
install_sudoers_rule 00-wheel-nopasswd "%wheel ALL=(ALL:ALL) NOPASSWD: ALL"

echo "==> Setting Neovim as default visudo editor..."
install_sudoers_rule 01-visudo-editor "Defaults editor=/usr/bin/nvim"
