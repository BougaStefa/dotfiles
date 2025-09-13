#!/bin/bash

set -e

GIT_CONFIG_DIR="$HOME/.config/git"
GIT_CONFIG_FILE="$GIT_CONFIG_DIR/config"

echo "==> Ensuring git config directory exists at $GIT_CONFIG_DIR..."
mkdir -p "$GIT_CONFIG_DIR"
touch "$GIT_CONFIG_FILE"

echo "==> Setting common git aliases and options..."
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global init.defaultBranch master
git config --global dieff.colorMoved zebra
git config --global rebase.autoStash true
git config --global fetch.prune true

if [[ -n "${USER_NAME//[[:space:]]/}" ]]; then
  echo "==> Setting git user.name to '$USER_NAME'..."
  git config --global user.name "$USER_NAME"
fi

if [[ -n "${USER_EMAIL//[[:space:]]/}" ]]; then
  echo "==> Setting git user.email to '$USER_EMAIL'..."
  git config --global user.email "$USER_EMAIL"
fi

echo "==> Git configuration complete."

