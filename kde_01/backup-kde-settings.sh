#!/bin/bash

# === KDE Settings Backup Script (KDE-specific .config only) ===

# Set backup destination and temp directory
BACKUP_DIR="$HOME/git/arch_config/kde_01/"
TEMP_DIR=$(mktemp -d)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="kde-settings-backup-$TIMESTAMP.tar.gz"
ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"

mkdir -p "$BACKUP_DIR"

echo "📦 Backing up KDE-specific settings..."

# List of KDE-specific config files/folders from ~/.config
KDE_CONFIG_ITEMS=(
  "plasma-org.kde.plasma.desktop-appletsrc"
  "powermanagementprofilesrc"
  "kglobalshortcutsrc"
  "kwinrc"
  "kdeglobals"
  "kcminputrc"
  "kscreenlockerrc"
  "ksmserverrc"
  "plasmashellrc"
  "systemsettingsrc"
  "dolphinrc"
  "konsole*"
  "krunnerrc"
  "kactivitymanagerdrc"
  "khotkeysrc"
  "kwalletrc"
  "kate*"
  "gtkrc*"              # If you're using KDE's GTK theming
  "gtk-3.0"
  "kmixrc"
)

mkdir -p "$TEMP_DIR/.config"

# Copy KDE-specific items from ~/.config
for item in "${KDE_CONFIG_ITEMS[@]}"; do
  matches=$(find "$HOME/.config" -maxdepth 1 -name "$item")
  for match in $matches; do
    cp -r "$match" "$TEMP_DIR/.config/"
  done
done

# Copy relevant parts of .local/share (e.g., Plasma data, Konsole profiles)
LOCAL_SHARE_ITEMS=(
  "konsole"
  "plasma*"
  "icons*"
  "kxmlgui5"
  "kwalletd"
  "knewstuff3"
  "kactivitymanagerd"
  "applications"
  "kservices5"
)

mkdir -p "$TEMP_DIR/.local/share"

for item in "${LOCAL_SHARE_ITEMS[@]}"; do
  matches=$(find "$HOME/.local/share" -maxdepth 1 -name "$item")
  for match in $matches; do
    cp -r "$match" "$TEMP_DIR/.local/share/"
  done
done

# Check and copy .kde or .kde4 if they exist
[ -d "$HOME/.kde" ] && cp -r "$HOME/.kde" "$TEMP_DIR/"
[ -d "$HOME/.kde4" ] && cp -r "$HOME/.kde4" "$TEMP_DIR/"

# Create the archive
echo "📁 Creating archive: $ARCHIVE_PATH"
tar -czf "$ARCHIVE_PATH" -C "$TEMP_DIR" .

# Clean up
rm -rf "$TEMP_DIR"

echo "✅ KDE settings backed up to: $ARCHIVE_PATH"
