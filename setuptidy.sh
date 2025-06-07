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
    echo "1) Base Config Deploy"
    echo "2) KDE Config Deploy"
    echo "3) Hyprland 01 Config Deploy"
    echo "4) i3_01 Config Deploy" 
	echo "5) ***"
	echo "6) ***"
    echo "7) Returning to main menu"
    echo

    read -p "Enter choice [1-7]: " choice
    case $choice in
      1) echo "Base Config deployment... " && stow_from_config base base/stow.config && sleep 5 ;;
      2) echo "Installing KDE config files" && sleep 2 && restore_kde_settings kde_01/restore.tar.gz && sleep 5 ;;
      3) echo "Hypr_01 config deployment" && stow_from_config hypr_01 hypr_01/stow.config && sleep 5 ;;
      4) echo "i3_01 config deployment" && stow_from_config i3_01 i3_01/stow.config && sleep 5 ;;
	  5) echo "" ;;
      6) echo "" ;;
	  7) echo "Return to main menu." && sleep 2; return 1 ;;
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
    echo "1) UPDATE - System Update"
    echo "2) INSTALL - Base System"
    echo "3) INSTALL - Extra packages"
    echo "4) INSTALL - Hyprland packages"
	echo "5) INSTALL - i3 packages"
    echo "6) SERVICES - Start Services for new build"
	echo "7) CONFIG - Deploy custom configuration stowed packages"
	echo "8) Exit"
    echo

    read -p "Enter choice [1-8]: " choice
    case $choice in
      1) update_Pacman && tweak_Pacman && check_AUR && check_Refelector ;;
      2) echo "Installing base packages..." && sleep 2 && install_packages "${PACKAGES[@]}" && sleep 2 ;;
      3) echo "Installing Extra packages..." && sleep 2 && install_packages "${EXTRA[@]}" && sleep 2 ;;
      4) echo "Installing Hyprland packages..." && sleep 2 && install_packages "${HYPRLAND[@]}" && sleep 2 ;;
      5) echo "Installing i3wm packages..." && sleep 2 && install_packages "${i3wm[@]}" && sleep 2 ;;
      6) echo "Starting Services..." && sleep 2 && start_syncthing && start_bluetooth && start_firewall && start_tlp;;
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

start_tlp() {
  read -p "Do you want to start the thinkpad Service? (y/n): " yn
  case $yn in
    [Yy]* )
      echo "Starting thinkpad services..."
       systemctl --user enable tlp --now
     sleep 4
      ;;
    [Nn]* ) ;;
    * ) echo "Please enter yes or no." ;;
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

restore_kde_settings() {
  local ARCHIVE="$1"

  # Check if argument was provided
  if [ -z "$ARCHIVE" ]; then
    echo "Usage: restore_kde_settings [path/to/kde-settings-backup.tar.gz]"
    return 1
  fi

  # Validate archive file
  if [ ! -f "$ARCHIVE" ]; then
    echo "❌ Archive not found: $ARCHIVE"
    return 1
  fi

  echo "⚠️  Make sure you are logged out of KDE before restoring settings!"
  read -rp "Continue with restore? [y/N]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    return 0
  fi

  # Extract backup
  echo "Restoring KDE settings from $ARCHIVE..."
  tar -xzf "$ARCHIVE" -C "$HOME"

  # Fix permissions
  chown -R "$USER:$USER" "$HOME/.config" "$HOME/.local" "$HOME/.kde*" 2>/dev/null

  echo "✅ Restore complete."
  echo "Please log out and log back in to KDE to apply your restored settings."
}



#########################

stow_impact() {
  local packages_root="$1"
  local package_list_file="$2"
  local target_dir="$HOME"

  if [[ ! -d "$packages_root" ]]; then
    echo "Packages root directory '$packages_root' does not exist." >&2
    return 1
  fi
  if [[ ! -f "$package_list_file" ]]; then
    echo "Package list file '$package_list_file' does not exist." >&2
    return 1
  fi

  declare -A seen

  while IFS= read -r package_name || [[ -n "$package_name" ]]; do
    [[ -z "$package_name" || "$package_name" =~ ^# ]] && continue

    local package_dir="$packages_root/$package_name"
    if [[ ! -d "$package_dir" ]]; then
      echo "Package directory '$package_dir' does not exist. Skipping." >&2
      continue
    fi

    (
      cd "$package_dir" || exit

      find . -type f -path "./.config/*" -print0 | while IFS= read -r -d '' file; do
        local rel_path="${file#./}"
        # Remove ".config/" prefix
        local config_subpath="${rel_path#".config/"}"

        # Top-level item (e.g. nvim/init.vim or .editorconfig)
        local top_level="${config_subpath%%/*}"

        # Handle case where file is directly under .config (no slash in subpath)
        if [[ "$config_subpath" == "$top_level" ]]; then
          echo "$target_dir/.config/$top_level"
        elif [[ -n "$top_level" && -z "${seen[$top_level]}" ]]; then
          echo "$target_dir/.config/$top_level"
          seen["$top_level"]=1
        fi
      done
    )
  done < "$package_list_file"
}



stow_from_config() {
  local packages_root="$1"
  local package_list_file="$2"
  local target_dir="$HOME"

  if [[ ! -d "$packages_root" ]]; then
    echo "Packages root directory '$packages_root' does not exist." >&2
    return 1
  fi
  if [[ ! -f "$package_list_file" ]]; then
    echo "Package list file '$package_list_file' does not exist." >&2
    return 1
  fi

  echo "Gathering files and directories to delete..."
  # Capture stow_impact output into an array
  mapfile -t paths_to_delete < <(stow_impact "$packages_root" "$package_list_file")

  echo "Deleting files..."
  for path in "${paths_to_delete[@]}"; do
    if [[ -L "$path" || -f "$path" ]]; then
      echo "Removing file or symlink: $path"
      rm -f "$path"
    fi
  done

  echo "Deleting empty directories..."
  # Attempt to delete directories listed (only if empty)
  # Sorting descending to remove nested dirs before parents
  for path in $(printf '%s\n' "${paths_to_delete[@]}" | sort -r); do
    if [[ -d "$path" ]]; then
      if rmdir --ignore-fail-on-non-empty "$path" 2>/dev/null; then
        echo "Removed empty directory: $path"
      fi
    else
      # Also try to remove parent dirs if empty
      local parent
      parent=$(dirname "$path")
      while [[ "$parent" != "$target_dir" && "$parent" != "/" ]]; do
        if rmdir --ignore-fail-on-non-empty "$parent" 2>/dev/null; then
          echo "Removed empty parent directory: $parent"
          parent=$(dirname "$parent")
        else
          break
        fi
      done
    fi
  done

  echo "Running stow on packages..."
  while IFS= read -r package_name || [[ -n "$package_name" ]]; do
    [[ -z "$package_name" || "$package_name" =~ ^# ]] && continue
    if [[ -d "$packages_root/$package_name" ]]; then
      echo "Stowing: $package_name"
      stow -d "$packages_root" -t "$target_dir" "$package_name"
    else
      echo "Warning: Package '$package_name' not found in '$packages_root'. Skipping." >&2
    fi
  done < "$package_list_file"

  echo "Done."
}





#####################
### Start of code ###
#####################

# Import data from packages config file
source packages.conf

# Launch main menu
user_Choice || exit 1
