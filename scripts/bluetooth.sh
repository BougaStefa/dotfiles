#!/bin/bash

set -e

echo "==> Enabling and starting Bluetooth service..."
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

echo "==> Bluetooth setup complete."
