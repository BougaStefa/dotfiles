#!/bin/bash

set -e

if gum confirm "Installation complete. Reboot now?"; then
  echo "==> Rebooting system..."
  sleep 5
  sudo reboot
else
  echo "==> Reboot cancelled. Please reboot manually when ready."
fi

