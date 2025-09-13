#!/bin/bash

set -e

echo "==> Enabling iwd service for wireless networking..."
sudo systemctl enable iwd.service

echo "==> Disabling and masking systemd-networkd-wait-online.service..."
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

