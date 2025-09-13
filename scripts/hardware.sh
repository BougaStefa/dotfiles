#!/bin/bash

set -e

echo "==> Disabling USB autosuspend..."
if [[ ! -f /etc/modprobe.d/disable-usb-autosuspend.conf ]]; then
  echo "options usbcore autosuspend=-1" | sudo tee /etc/modprobe.d/disable-usb-autosuspend.conf
fi


echo "==> Enabling touchpad tapping in libinput config..."
if [[ ! -f /etc/X11/xorg.conf.d/40-libinput.conf ]]; then
  sudo tee /etc/X11/xorg.conf.d/40-libinput.conf >/dev/null <<'EOF'
Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        # Enable left mouse button by tapping
        Option "Tapping" "on"
EndSection
EOF
fi

echo "==> Hardware tweaks complete."
