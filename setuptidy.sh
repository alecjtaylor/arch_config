#!/bin/bash

#######################
### Functions below ###
#######################

# Function to test config
custom_Config() {
  while true; do
  clear
    cat << "EOF"

 ###############################################################################
 ###############################################################################
 ##    ______           __                     ______            _____        ##
 ##   / ____/_  _______/ /_____  ____ ___     / ____/___  ____  / __(_)___ _  ##
 ##  / /   / / / / ___/ __/ __ \/ __ `__ \   / /   / __ \/ __ \/ /_/ / __ `/  ##
 ## / /___/ /_/ (__  ) /_/ /_/ / / / / / /  / /___/ /_/ / / / / __/ / /_/ /   ##
 ## \____/\__,_/____/\__/\____/_/ /_/ /_/   \____/\____/_/ /_/_/ /_/\__, /    ##
 ##                                                                /____/     ##
 ###############################################################################
 ###############################################################################

EOF

    echo -e "\nChoose an option:\n"
    echo "1) Base Config Customisation - Deploy"
    echo "2) Base Config Customisation - Roll Back"
    echo "3) Hyprland 01 - Deploy"
    echo "4) Hyprland 01 - Roll Back" 
	echo "5) i3 01 - Deploy"
	echo "6) i3 01 - Roll Back"
    echo "7) Returning to main menu"
    echo

    read -p "Enter choice [1-5]: " choice
    case $choice in
      1) echo "Base Config deployment... " && stow_from_config base stow.config && sleep 5 ;;
      2) echo "Base Config rollback" && stow_from_config base stow.config --unstow && sleep 5 ;;
      3) echo "Hyprland 01" && sleep 2 ;;
      4) echo "i3 01" && sleep 3 ;;
	  5) echo ""
      6) echo ""
	  7) echo "Return to main menu." && sleep 1.5; return 1 ;;
      *) echo "Invalid option." ;;
    esac
  done
}

# Main menu
user_Choice() {
  while true; do
    clear
    cat << "EOF"

 #############################################################
 #############################################################
 ##     ___              __       _____      __             ##
 ##    /   |  __________/ /_     / ___/___  / /___  ______  ##
 ##   / /| | / ___/ ___/ __ \    \__ \/ _ \/ __/ / / / __ \ ##
 ##  / ___ |/ /  / /__/ / / /   ___/ /  __/ /_/ /_/ / /_/ / ##
 ## /_/  |_/_/   \___/_/ /_/   /____/\___/\__/\__,_/ .___/  ##
 ##                                               /_/       ##
 ##              By AJCT - alecjtaylor.com                  ##
 #############################################################
 #############################################################

EOF

    echo -e "\nChoose an option:\n"
    echo "1) System Update"
    echo "2) Base System Install"
    echo "3) Hyprland Install"
    echo "4) Start Services for new build"
    echo "5) *** KDE (NOT YET FUNCTIONAL) ***"
    echo "6) *** i3wm (NOT YET FUNCTIONAL) ***"
    echo "7) Deploy custom config"
    echo "8) Exit"
    echo

    read -p "Enter choice [1-8]: " choice
    case $choice in
      1) update_Pacman && tweak_Pacman && check_AUR && check_Refelector ;;
      2) echo "Installing base packages..." && sleep 2 && install_packages "${PACKAGES[@]}" ;;
      3) echo "Installing Hyprland packages..." && sleep 2 && install_packages "${HYPRLAND[@]}" ;;
      4) echo "Starting Services..." && sleep 2 && start_syncthing && start_bluetooth && start_firewall && start_stow ;;
      5) echo "Coming soon for KDE..." && sleep 2 ;; # tweak_ssdm
      6) echo "Coming soon for i3wm..." && sleep 2 ;; # tweak_ssdm
      7) echo "Setting up custom configuration..." & sleep 2 && custom_Config ;;
      8) echo "Bye!"; return 1 ;;
      *) echo "Invalid option." ;;
    esac
  done
}

is_group_installed() {
  pacman -Qg "$1" &> /dev/null
}

is_installed() {
  pacman -Qi "$1" &> /dev/null
}

install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
      to_install+=("$pkg")
    else
      echo "$pkg is already installed."
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "Installing: ${to_install[*]}"
    yay -Syu --noconfirm "${to_install[@]}"
  fi
}

replace_line_in_file() {
  local file="$1"
  local search="$2"
  local replacement="$3"

  if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    return 1
  fi

  local escaped_search
  escaped_search=$(printf '%s\n' "$search" | sed -e 's/[]\/$*.^[]/\\&/g')

  local escaped_replacement
  escaped_replacement=$(printf '%s\n' "$replacement" | sed -e 's/[&/\]/\\&/g')

  sudo sed -i.bak "s/^$escaped_search\$/$escaped_replacement/" "$file"

  printf "Line replaced in '$file'.\n$escaped_search was replaced with $escaped_replacement.\nBackup saved as '$file.bak'.\n\n"
}

#####################
### Arch Specific ###
#####################

update_Pacman() {
  echo -e "\nUpdating system...\n"
  sudo pacman -Syu --noconfirm
}

tweak_Pacman() {
  read -p "Do you want to add tweaks to pacman? (y/n): " yn
  case $yn in
    [Yy]*) 
      replace_line_in_file "/etc/pacman.conf" "#Color" "Color"
      replace_line_in_file "/etc/pacman.conf" "# Misc options" "ILoveCandy"
      replace_line_in_file "/etc/pacman.conf" "#VerbosePkgLists" "VerbosePkgLists"
      ;;
    [Nn]*) echo "No action will be taken." ;;
    *) echo "Please answer yes or no." ;;
  esac
}

check_AUR() {
  if ! command -v yay &> /dev/null; then
    echo "Installing yay AUR helper..."
    sudo pacman -S --needed git base-devel --noconfirm

    [[ -d yay ]] && echo "Removing existing yay directory..." && rm -rf yay

    git clone https://aur.archlinux.org/yay.git
    cd yay
    echo "Building yay..."
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
  else
    echo "yay is already installed."
  fi
}

check_Refelector() {
  read -p "Do you want to install and configure reflector? (y/n): " yn
  case $yn in
    [Yy]* )
      install_packages "reflector"
      echo "Configuring pacman mirrorlist..."
      sudo reflector --country '' --latest 50 --sort rate --save /etc/pacman.d/mirrorlist
      echo "Changes to pacman mirror list:"
      cat /etc/pacman.d/mirrorlist
      ;;
    [Nn]* ) ;;
    * ) echo "Please answer 'y' or 'n'." ;;
  esac
}

tweak_ssdm() {
  read -p "Do you want to customise SDDM as a login manager? (y/n): " yn
  case $yn in
    [Yy]* )
      sudo sddm --example-config | sudo tee /etc/sddm.conf > /dev/null
      replace_line_in_file "/etc/sddm.conf" "Current=" "Current=sddm-sugar-dark"
      ;;
    [Nn]* ) ;;
    * ) echo "Please enter 'y' or 'n'." ;;
  esac
}

start_syncthing() {
  read -p "Do you want to start the Syncthing Service? (y/n): " yn
  case $yn in
    [Yy]* )
      echo "Starting Syncthing..."
      systemctl --user enable syncthing.service
      systemctl --user start syncthing.service
      echo "Please configure Syncthing to bring down the 'stow' folder to this machine."
      sleep 4
      xdg-open "http://127.0.0.1:8384/"
      ;;
    [Nn]* ) ;;
    * ) echo "Please enter yes or no." ;;
  esac
}

start_bluetooth() {
  read -p "Do you want to start the Bluetooth Service? (y/n): " yn
  case $yn in
    [Yy]* )
      echo "Starting Bluetooth..."
      systemctl enable bluetooth.service
      systemctl start bluetooth.service
      ;;
    [Nn]* ) ;;
    * ) echo "Please enter yes or no." ;;
  esac
}

start_network() {
  read -p "Do you want to start the Network Manager Service? (y/n): " yn
  case $yn in
    [Yy]* )
      echo "Starting NetworkManager..."
      systemctl enable NetworkManager.service
      systemctl start NetworkManager.service
      ;;
    [Nn]* ) ;;
    * ) echo "Please enter yes or no." ;;
  esac
}

start_firewall() {
  read -p "Do you want to set up a firewall? (y/n): " yn
  case $yn in
    [Yy]* )
      install_packages ufw
      sudo systemctl enable --now ufw
      sudo ufw default allow outgoing
      sudo ufw default deny incoming
      ;;
    [Nn]* ) ;;
    * ) echo "Please enter yes or no." ;;
  esac
}

start_stow() {
  read -p "Do you want to set up stow config linking now? (y/n): " yn
  case $yn in
    [Yy]* )
      if command -v stow >/dev/null 2>&1; then
        echo "Stow is installed. Checking for local directory..."
        if [ -d "$HOME/stow" ]; then
          cd "$HOME/stow"
          rm ~/.bashrc
          for dir in bash starship fastfetch nvim vim wallpaper kitty hypr waybar yay reaper ranger wofi; do
            stow "$dir"
          done
        fi
      fi
      ;;
    [Nn]* ) ;;
    * ) echo "Please enter 'y' or 'no'." ;;
  esac
}


#########################
stow_from_config() {
  local stow_base_dir="$1"
  local config_file="$2"
  local mode="$3"  # optional: "--unstow"
  local original_dir
  original_dir="$(pwd)"

  # Validate arguments
  if [[ -z "$stow_base_dir" || -z "$config_file" ]]; then
    echo "Usage: run_stow_from_config <stow_base_dir> <config_file> [--unstow]"
    return 1
  fi

  local base_path="$original_dir/$stow_base_dir"
  local config_path="$base_path/$config_file"

  if [[ ! -d "$base_path" ]]; then
    echo "❌ Error: Directory '$base_path' not found."
    return 1
  fi

  if [[ ! -f "$config_path" ]]; then
    echo "❌ Error: Config file '$config_path' not found."
    return 1
  fi

  # Build stow arguments
  local stow_args=(-t "$HOME")
  if [[ "$mode" == "--unstow" ]]; then
    stow_args=(-D -t "$HOME")
    echo "🔁 Unstowing mode"
  else
    echo "✅ Stowing mode"
  fi

  # Change into stow base dir
  cd "$base_path" || {
    echo "❌ Could not cd into $base_path"
    return 1
  }

  echo "📂 Running in: $base_path"
  echo "📄 Using config: $config_file"

  # Loop through each line
while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty lines and comments
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  if [[ -d "$line" ]]; then
    local target_path="$HOME/.config/$line"

    if [[ "$mode" == "--unstow" ]]; then
      echo "➖ Unstowing: $line"
      stow -D "$line"

      # Check for backups
      backup_glob="$target_path.backup.*"
      latest_backup=$(ls -t $backup_glob 2>/dev/null | head -n 1)

      if [[ -n "$latest_backup" ]]; then
        read -p "🗂️  Restore backup from $latest_backup? (y/n): " yn < /dev/tty
        case "$yn" in
          [Yy]* )
            mv "$latest_backup" "$target_path"
            echo "✅ Restored backup to: $target_path"
            ;;
          * )
            echo "⏩ Skipping restore for: $line"
            ;;
        esac
      fi

    else
      # Stow mode
      if [[ -e "$target_path" ]]; then
        echo "⚠️  Existing config detected at: $target_path"
        read -p "❓ Backup and remove '$target_path' before stowing '$line'? (y/n): " yn < /dev/tty

        case "$yn" in
          [Yy]* )
            timestamp=$(date +%Y%m%d_%H%M%S)
            backup_path="$target_path.backup.$timestamp"
            mv "$target_path" "$backup_path"
            echo "💾 Backed up to: $backup_path"
            ;;
          [Nn]* )
            echo "⏩ Skipping $line"
            continue
            ;;
          * )
            echo "❌ Invalid response. Skipping $line."
            continue
            ;;
        esac
      fi

      echo "➕ Stowing: $line"
      stow -t "$HOME" "$line"
    fi

  else
    echo "⚠️  Skipping: '$line' not found in $base_path"
  fi
done < "$config_path"

  # Return to original directory
  cd "$original_dir"
}




#####################
### Start of code ###
#####################

# Import data from packages config file
source packages.conf

# Launch main menu
user_Choice || exit 1
