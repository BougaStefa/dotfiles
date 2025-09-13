#!/bin/bash

set -e

TPM_PATH="${HOME}/.config/tmux/plugins/tpm"

echo "==> Checking for TPM at $TPM_PATH..."
if [ ! -d "$TPM_PATH" ]; then
    echo "==> TPM not found. Installing..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
    echo "==> TPM installed successfully."
else
    echo "==> TPM already installed."
fi
