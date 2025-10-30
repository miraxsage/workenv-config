#!/usr/bin/env bash
set -e # stop on error

# dir to install
TARGET="$HOME"

# configs to install
PACKAGES=(
  alacritty
  tmux
  zsh
  nvim
)

echo "📦 Installing dotfiles to $TARGET..."
cd "$(dirname "$0")"

for pkg in "${PACKAGES[@]}"; do
  echo "➡️  Linking $pkg..."
  stow -R -v -t "$TARGET" "$pkg"
done

echo "✅ Done!"
