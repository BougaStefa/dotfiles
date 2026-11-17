#!/bin/bash

set -e

echo "==> Enabling iwd service for wireless networking..."
sudo systemctl enable iwd.service

echo "==> Disabling and masking systemd-networkd-wait-online.service..."
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

echo "==> Enabling Tailscale..."
sudo systemctl enable --now tailscaled.service
echo "    Run 'sudo tailscale up' to join the tailnet."

echo "==> Enabling the user ssh-agent socket..."
systemctl --user enable ssh-agent.socket
