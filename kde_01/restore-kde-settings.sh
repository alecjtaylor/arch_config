#!/bin/bash

# === KDE Settings Restore Script ===

# Usage message
usage() {
  echo "Usage: $0 [path/to/kde-settings-backup.tar.gz]"
  exit 1
}

# Require tar archive path as argument or prompt for it
ARCHIVE="$1"
if [ -z "$ARCHIVE" ]; then
  read -rp "Enter path to your KDE settings backup archive (.tar.gz): " ARCHIVE
fi

# Validate archive
if [ ! -f "$ARCHIVE" ]; then
  echo "❌ Archive not found: $ARCHIVE"
  exit 1
fi

echo "⚠️  Make sure you are logged out of KDE before restoring settings!"
read -rp "Continue with restore? [y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

# Extract backup to home directory
echo "Restoring KDE settings from $ARCHIVE..."
tar -xzf "$ARCHIVE" -C "$HOME"

# Fix permissions just in case (especially if run with sudo)
chown -R "$USER:$USER" "$HOME/.config" "$HOME/.local" "$HOME/.kde*" 2>/dev/null

echo "✅ Restore complete."
echo "Please log out and log back in to KDE to apply your restored settings."
