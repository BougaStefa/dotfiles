#!/bin/bash

set -e

SUCKLESS_REPOS=(
  "https://github.com/BougaStefa/dwm.git"
  "https://git.suckless.org/dmenu"
)
INSTALL_DIR="$HOME/.local/src"

mkdir -p "$INSTALL_DIR"

for repo in "${SUCKLESS_REPOS[@]}"; do
  progname="${repo##*/}"
  progname="${progname%.git}"
  dir="$INSTALL_DIR/$progname"

  echo "==> Installing $progname from $repo..."

  if [[ ! -d "$dir" ]]; then
    sudo -u "$USER" git clone --depth 1 "$repo" "$dir"
  else
    cd "$dir"
    sudo -u "$USER" git pull --force origin master
  fi

  cd "$dir"
  make
  sudo make install
done

echo "==> Suckless programs installed."
