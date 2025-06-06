#!/bin/bash

#######################
### Functions below ###
#######################

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

'''
Todo list

1) Make i3 install option work 

2) set up prompt for which set of config to 'stow' 
		base config options should be avaliable
		each 'rice' should be completely self contained. 

'''

echo -e "\nChoose an option:\n\n1) System Update\n2) Base System Install\n3) Hyprland Install\n4) Start Services for new build\n5) KDE (NOT YET FUNCTIONAL) \n6) i3wm (NOT YET FUNCTIONAL)\n7) Deploy custom config\n8) Exit"
    read -p "Enter choice [1-7]: " choice

    case $choice in
      1) update_Pacman && tweak_Pacman && check_AUR && check_Refelector ;;
      2) echo -e "Installing base packages..." && sleep 2 &&install_packages "${PACKAGES[@]}" && sleep 2;;
      3) echo -e "Installing Hyprland packages..." && sleep 2 && install_packages "${HYPRLAND[@]}" && sleep 2;;
      4) echo -e "Starting Services..." && start_syncthing && start_bluetooth && start_firewall && start_stow && sleep 3;; 
      5) echo -e "Coming soon for KDE..." && sleep 3;; #tweak_ssdm
      6) echo -e "Coming soon for i3wm..." && sleep 3;; #tweak_ssdm
	    7) printf "calling stow options..." && sleep 3;; 
	    8) echo -e "Bye!"; return 1 ;;
      *) echo -e "Invalid option." ;;
    esac
  done
}

# Function to check if a package is installed
is_group_installed() {
  pacman -Qg "$1" &> /dev/null
}

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &> /dev/null
}

# Function to install packages if not already installed
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

# Function to replace a line in a file
replace_line_in_file() {
  local file="$1"
  local search="$2"
  local replacement="$3"

  if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    return 1
  fi

  # Escape slashes and special characters
  local escaped_search
  escaped_search=$(printf '%s\n' "$search" | sed -e 's/[]\/$*.^[]/\\&/g')

  local escaped_replacement
  escaped_replacement=$(printf '%s\n' "$replacement" | sed -e 's/[&/\]/\\&/g')

  # Replace the matching line
  sudo sed -i.bak "s/^$escaped_search\$/$escaped_replacement/" "$file"

  printf "Line replaced in '$file'. \n $escaped_search was replaced with $escaped_replacement. \nBackup saved as '$file.bak'.\n\n"
}

#####################
### Arch Specific ###
#####################

update_Pacman() {
  echo -e "\nUpdating system...\n"
  sudo pacman -Syu --noconfirm
}

tweak_Pacman() {
  echo -e "\nDo you want to add tweaks to pacman? (y/n): " 
  read yn
  case $yn in
    [Yy]* ) 
      replace_line_in_file "/etc/pacman.conf" "#Color" "Color" 
      replace_line_in_file "/etc/pacman.conf" "# Misc options" "ILoveCandy"
      replace_line_in_file "/etc/pacman.conf" "#VerbosePkgLists" "VerbosePkgLists"
    ;; 
    [Nn]* ) echo "No action will be taken." ;;
    * ) echo "Please answer yes or no.";;
  esac
}

check_AUR(){
    if ! command -v yay &> /dev/null; then
    echo "Installing yay AUR helper..."
    sudo pacman -S --needed git base-devel --noconfirm
    if [[ ! -d "yay" ]]; then
      echo "Cloning yay repository..."
    else
      printf "yay directory already exists, removing it before build"
      rm -rf yay
    fi

    git clone https://aur.archlinux.org/yay.git

    cd yay
    printf "building yay.... yaaaaayyyyy"
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
    else
    printf "yay is already installed"
    fi
}

check_Refelector() {
		printf "\nDo you want to install and configure reflector? (y/n): "
		read yn
		case $yn in
				[Yy]* )
						install_packages "reflector"
						printf "\nconfiguring pacman for speed....don't worry about the [WARNINGS]\n"
						sudo reflector --country '' --latest 50 --sort rate --save /etc/pacman.d/mirrorlist

						printf "\nChanges to pacman mirror list:\n\n"
						cat /etc/pacman.d/mirrorlist
						printf "\n" 
						;;
				[Nn]* ) ;;
				* ) echo "Please answer 'y' or 'n'.";;
		esac				
}

tweak_ssdm(){
read -p "Do you want to customise SDDM as a login manager? (y/n): " yn
case $yn in
        [Yy]* )
                {
                        sudo sddm --example-config | sudo tee /etc/sddm.conf > /dev/null
                        replace_line_in_file "/etc/sddm.conf" "Current=" "Current=sddm-sugar-dark"
                }
                ;;
        [Nn]* ) ;;
        * ) echo "Please enter 'y' or 'n'.";;
esac
}

start_syncthing(){
read -p "Do you want to start the Syncthing Service? (y/n): " yn
case $yn in
        [Yy]* )
                {
                echo "Starting Syncthing..."
                systemctl --user enable syncthing.service
                systemctl --user start syncthing.service
                printf "Please configure Syncthing to bring down the 'stow' folder to this machine. "
                sleep 4 
                xdg-open "http://127.0.0.1:8384/"
                } ;;

        [Nn]* ) ;;
        * ) echo "please enter yes or no.";;
esac
}

start_bluetooth(){
read -p "Do you want to start the Bluetooth Service? (y/n): " yn
case $yn in
        [Yy]* )
                {
                echo "Starting Bluetooth..."
                systemctl enable bluetooth.service
                systemctl start bluetooth.service
                } ;;

        [Nn]* ) ;;
        * ) echo "please enter yes or no.";;
esac
}


start_network(){
read -p "Do you want to start the Network Manager Service? (y/n): " yn
case $yn in
        [Yy]* )
                {
                echo "Starting Bluetooth..."
                systemctl enable NetworkManager.service
                systemctl start NetworkManager.service
                } ;;

        [Nn]* ) ;;
        * ) echo "please enter yes or no.";;
esac
}



start_firewall()
{
read -p "Do you want to set up a firewall? (y/n): " yn
case $yn in
        [Yy]* )
                {
                install_packages ufw
                sudo systemctl enable --now ufw
                sudo ufw default allow outgoing
                sudo ufw default deny incoming
                } ;;

        [Nn]* ) ;;
        * ) echo "please enter yes or no.";;
esac
}

start_stow(){
read -p "Do you want to set up stow config linking now? (y/n): " yn
case $yn in
        [Yy]* )
                {
                if command -v stow >/dev/null 2>&1; then
                    printf "Stow is now installed, checked for local directory..."
                    if [ -d "~/stow" ]; then
                        cd "~/stow"
                        rm ~/.bashrc
                        stow bash
                        stow starship
                        stow fastfetch
                        stow nvim
                        stow vim
                        stow wallpaper
                        stow kitty
                        stow hypr
                        stow waybar
                        stow yay
                        stow reaper
                        stow ranger
                        stow wofi
                    fi
                fi
                };;
        [Nn]* ) ;;
        * ) echo "Please enter 'y' or 'no'.";;
esac
}



#####################
### Start of code ###
#####################

#TODO split up into base utils for all then distro specific tools

# import data from pacages config file
source packages.conf

user_Choice || exit 1



