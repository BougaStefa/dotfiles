#!/bin/bash

CSV_FILE="${HOME}/.dotfiles/data/packages.csv"

echo "==> Checking for package list: $CSV_FILE"
if [[ ! -f "$CSV_FILE" ]]; then
  echo "CSV file not found: $CSV_FILE"
  exit 1
fi

if [[ -n "$CATEGORY" ]]; then
  echo "==> Filtering packages by category: $CATEGORY"
else
  echo "==> Installing all packages from CSV"
fi

while IFS=, read -r pkg desc cat; do
  # Skip header or empty lines
  [[ "$pkg" == "package" || -z "$pkg" ]] && continue
  # Filter by category if set
  if [[ -n "$CATEGORY" && "$cat" != "$CATEGORY" ]]; then
    continue
  fi
  echo "==> Installing $pkg: $desc"
  yay -S --noconfirm --needed "$pkg"
done < "$CSV_FILE"

echo "==> Package installation complete."
