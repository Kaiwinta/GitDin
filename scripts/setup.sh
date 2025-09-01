#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# Detect OS (Ubuntu/Pop vs Arch)
# -------------------------------
if command -v apt-get >/dev/null 2>&1; then
  PKG_MANAGER="apt-get"
  echo "[*] Ubuntu/Pop!_OS detected"
elif command -v pacman >/dev/null 2>&1; then
  PKG_MANAGER="pacman"
  echo "[*] Arch Linux detected"
else
  echo "[-] Unsupported OS. Please install Node.js, npm, and pnpm manually."
  exit 1
fi

# -------------------------------
# Install system dependencies
# -------------------------------
if [ "$PKG_MANAGER" = "apt-get" ]; then
  sudo apt-get update -y
  sudo apt-get install -y curl git build-essential
elif [ "$PKG_MANAGER" = "pacman" ]; then
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm curl git base-devel
fi

# -------------------------------
# Install / Update NVM + Node.js 20.x LTS
# -------------------------------
echo "[*] Installing or updating NVM..."
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
  cd "$NVM_DIR"
  git fetch origin
  git checkout "$(git describe --abbrev=0 --tags)"
  cd -
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Load nvm into current shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "[*] Installing Node.js 20.x LTS via NVM..."
nvm install 20
nvm alias default 20
nvm use 20

# -------------------------------
# Update npm to latest
# -------------------------------
echo "[*] Updating npm globally..."
npm install -g npm@latest

# -------------------------------
# Install pnpm (via npm)
# -------------------------------
if ! command -v pnpm >/dev/null 2>&1; then
  echo "[*] Installing pnpm..."
  npm install -g pnpm
fi

# -------------------------------
# Install project dependencies
# -------------------------------
if [ -f "package.json" ]; then
  echo "[*] Installing project dependencies with pnpm..."
  pnpm install
else
  echo "⚠️  No package.json found in current directory, skipping pnpm install."
fi

echo ""
echo "✅ Setup complete."
echo "   - Node:  $(node -v || true)"
echo "   - npm:   $(npm -v || true)"
echo "   - pnpm:  $(pnpm -v || true)"
echo "   - nvm:   $(nvm --version || true)"
