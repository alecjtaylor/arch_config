#!/bin/bash

#######################
### Functions below ###
#######################

# Function to test config
custom_Config() {
  printf "testing"
}

# Main menu
user_Choice() {
  while true; do
    clear
    cat << "EOF"

 ######################################################
 ######################################################
 ##      _       _  ____ _____                       ##
 ##     / \     | |/ ___|_   _|                      ##
 ##    / _ \ _  | | |     | |                        ##
 ##   / ___ \ |_| | |___  | |    Set up Arch Linux   ##
 ##  /_/   \_\___/ \____| |_|    by AJCT             ##
 ##                                                  ##
 ######################################################
 ######################################################

EOF

    echo -e "\nChoose an option:\n"
    echo "1) System Update"
    echo "2) Base System Install"
    echo "3) Hyprland Install"
    echo "4) Start Services for new build"
    echo "5) KDE (NOT YET FUNCTIONAL)"
    echo "6) i3wm (NOT YET FUNCTIONAL)"
    echo "7) Deploy custom config"
    echo "8) Exit"
    echo

    read -p "Enter choice [1-8]: " choice
    case $choice in
      1) update_Pacman && tweak_Pacman && check_AUR && check_Refelector ;;
      2) echo "Installing base packages..." && sleep 2 && install_packages "${PACKAGES[@]}" && sleep 2 ;;
      3) echo "Installing Hyprland packages..." && sleep 2 && install_packages "${HYPRLAND[@]}" && sleep 2 ;;
      4) echo "Starting Services..." && start_syncthing && start_bluetooth && start_firewall && start_stow && sleep 3 ;;
      5) echo "Coming soon for KDE..." && sleep 3 ;; # tweak_ssdm
      6) echo "Coming soon for i3wm..." && sleep 3 ;; # tweak_ssdm
      7) echo "Calling stow options..." && sleep 3 ;;
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
      rep
