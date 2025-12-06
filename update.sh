#!/bin/bash
set -x

unamestr=$(uname)
if [[ "$unamestr" == 'Darwin' ]]; then
    #
    # Ensure Brew is installed and updated
    # 
    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc

        # Run the Brewfile
        brew bundle install --file=Brewfile

        #
        # Reset the dock
        #
        defaults delete com.apple.dock persistent-apps

        dock_item() {
            printf '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>', "$1"
        }

        defaults write com.apple.dock persistent-apps -array \
            "$(dock_item /Applications/Slack.app)" \
            "$(dock_item /Applications/Visual\ Studio\ Code.app)" \
            "$(dock_item /Applications/Google\ Chrome.app)" \
            "$(dock_item /Applications/Safari.app)" \
            "$(dock_item /System/Applications/Music.app)" \
            "$(dock_item /System/Applications/Messages.app)" \
            "$(dock_item /System/Applications/Utilities/Terminal.app)" \
            "$(dock_item /Applications/Obsidian.app)"
        killall Dock

    else
       brew update && brew upgrade && brew cleanup
       brew cu -a -f
       #brew bundle dump
    fi

    sudo pmset -c autorestart 1

    #
    # Update all apps from the Apple App Store
    #
    mas upgrade

    sudo brew services start tailscale

    #
    # MacOS Software Update 
    #
    softwareupdate -ia --verbose
    
elif [[ "$unamestr" == 'Linux' ]]; then
    # Export list of packages
    # dpkg --get-selections > rpi-packages.txt

    # Install baseline packages
    sudo dpkg --set-selections < rpi-packages.txt 
    sudo apt-get -y install

    # Update the list of available packages and their versions
    sudo apt-get update
    # Install available upgrades of all packages currently installed on the system
    sudo apt-get upgrade
    # Handle changing dependencies with new versions of packages
    sudo apt-get dist-upgrade
    # Perform a full upgrade, this may remove some packages in certain situations
    sudo apt full-upgrade
    # Update the Raspberry Pi firmware
    sudo rpi-update
    # Update the Raspberry Pi EEPROM images
    sudo rpi-eeprom-update
elif [[ "$unamestr" == 'FreeBSD' ]]; then

    pw usermod andy -G wheel

    pkg update
    pkg install sudo
    pkg install nano

fi

#
# Common
# 
npm install npm@latest -g
npm update -g
npx npm-check --global --update-all

# Update all Python / PIP packages
pip freeze --local | cut -d = -f 1 | xargs -n1 pip install --upgrade

