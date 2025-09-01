#!/usr/bin/env bash
set -e

# -------------------------------
# Detect OS (Ubuntu/Pop vs Arch)
# -------------------------------
if command -v apt-get >/dev/null; then
  PKG_MANAGER="apt-get"
  echo "[*] Ubuntu/Pop!_OS detected"
elif command -v pacman >/dev/null; then
  PKG_MANAGER="pacman"
  echo "[*] Arch Linux detected"
else
  echo "[-] Unsupported OS. Please install Node.js and pnpm manually."
  exit 1
fi

# -------------------------------
# Install system dependencies
# -------------------------------
if [ "$PKG_MANAGER" = "apt-get" ]; then
  sudo apt-get update
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
# Install pnpm
# -------------------------------
if ! command -v pnpm >/dev/null; then
  echo "[*] Installing pnpm..."
  npm install -g pnpm
fi

# -------------------------------
# Install frontend dependencies
# -------------------------------
echo "[*] Installing dependencies..."
pnpm install

# Vue Router + Pinia
pnpm add vue-router@4 pinia

# TailwindCSS + PostCSS + Autoprefixer
pnpm add -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

echo ""
echo "Setup complete!"
