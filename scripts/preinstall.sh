#!/bin/bash

set -e

export CATEGORY=$(gum input --placeholder "Install category (leave blank for default)")
export USER_NAME=$(gum input --placeholder "Your git user.name")
export USER_EMAIL=$(gum input --placeholder "Your git user.email")

echo "==> Variables exported to current shell session."

