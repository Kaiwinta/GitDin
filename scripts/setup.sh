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
# Install Node.js (22.x LTS)
# -------------------------------
if [ "$PKG_MANAGER" = "apt-get" ]; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
elif [ "$PKG_MANAGER" = "pacman" ]; then
  sudo pacman -S --noconfirm nodejs npm
fi

# -------------------------------
# Update npm to latest
# -------------------------------
echo "[*] Updating npm globally..."
sudo npm install -g npm@latest

# -------------------------------
# Install pnpm (via npm)
# -------------------------------
if ! command -v pnpm >/dev/null 2>&1; then
  echo "[*] Installing pnpm..."
  sudo npm install -g pnpm
fi

echo ""
echo "✅ System dependencies installed."
echo "   - Node:  $(node -v || true)"
echo "   - npm:   $(npm -v || true)"
echo "   - pnpm:  $(pnpm -v || true)"
