#!/bin/bash

CSV_FILE="${HOME}/.dotfiles/data/packages.csv"

if [[ ! -f "$CSV_FILE" ]]; then
  echo "CSV file not found: $CSV_FILE"
  exit 1
fi

# Optional: set CATEGORY to filter, e.g. CATEGORY="dev"
CATEGORY="$1"

while IFS=, read -r pkg desc cat; do
  # Skip header or empty lines
  [[ "$pkg" == "package" || -z "$pkg" ]] && continue
  # Filter by category if set
  if [[ -n "$CATEGORY" && "$cat" != "$CATEGORY" ]]; then
    continue
  fi
  echo "Installing $pkg: $desc"
  yay -S --noconfirm --needed "$pkg"
done < "$CSV_FILE"
