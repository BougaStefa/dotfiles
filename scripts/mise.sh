echo "==> Setting up mise and installing global tools..."

if ! command -v mise &> /dev/null; then
  echo "mise not found in PATH."
  exit 1
fi

echo "==> Installing tools from ~/.config/mise/config.toml..."
mise install -y

echo "==> mise setup complete."
mise list
