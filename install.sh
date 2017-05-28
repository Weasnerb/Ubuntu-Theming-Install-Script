#!/bin/bash

function checkPrivileges {
    if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "Insufficient privileges"
        exit
    fi
}


###########################
###### Before Reboot ######
###########################

function beforeReboot {
    checkPrivileges
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        setDirectoryAndInstallGit
        addReposToPackageManager
        addThemes
        updateAndUpgrade
        installApps
        addAppsToStartupApplications
        installGrubHoldshift
        removeUnusedPackages
        configure
        addScriptToStartup
    else
        echo "No Network Connection, Please Connect to the Internet"
    fi
}

function setDirectoryAndInstallGit {
    # Get ScriptPath
    pushd `dirname $0` > /dev/null
    SCRIPTPATH=`pwd`
    popd > /dev/null

    # Make Working Directory The Downloads Folder
    cd ~/Downloads

    # Install Git
    sudo apt-get -y install git
}

function addReposToPackageManager {
    # Add Xenlism-Minimalism repo to Package Manager
    sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 90127F5B
    echo "deb http://downloads.sourceforge.net/project/xenlism-wildfire/repo deb/" | sudo tee -a /etc/apt/sources.list

    # Add Planky repo to Package Manager for Plank
    sudo add-apt-repository -y ppa:ricotz/docky

    # Add Ruby Repo to Package Manager
    sudo apt-add-repository -y ppa:brightbox/ruby-ng

    # Allow Installation of Partner Apps
    sudo add-apt-repository -y "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
}

function addThemes {
    # Ardis Icons
    git clone https://github.com/Nitrux/ardis-icon-theme.git
    sudo cp -a ardis-icon-theme/. /usr/share/icons/Ardis-Icons
    rm -rf ardis-icon-theme/

    # Uranus Shell Theme
    wget https://dl.opendesktop.org/api/files/download/id/1463299235/174476-Uranus-V0.0.2.tar.gz
    tar -xvf 174476-Uranus-V0.0.2.tar.gz
    sudo cp -a Uranus-V0.0.2/. /usr/share/themes/Uranus-V0.0.2
    rm 174476-Uranus-V0.0.2.tar.gz
    rm -rf Uranus-V0.0.2/
}

function updateAndUpgrade {
    sudo apt-get -y update
    sudo apt-get -y upgrade
}

function installApps {
    installPackageManagedApps
    installNonPackageManagedApps
}

function installPackageManagedApps {
     # Install Gnome Desktop
    sudo apt-get -y install ubuntu-gnome-desktop

    # Install Gnome-Tweak-Tool
    sudo apt-get -y install gnome-tweak-tool

    # Install Xenlism-Minimalism-Theme
    sudo apt-get --allow-unauthenticated -y install xenlism-minimalism-theme
    
    # Install General Apps
    sudo apt-get -y install plank ruby2.3 ruby2.3-dev skype virtualbox
}

function installNonPackageManagedApps {
    downloadAndInstallDebFiles
    installRubyMine
}

function downloadAndInstallDebFiles {
    # Download and install Google Chrome
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome*.deb
    sudo apt-get -y install -f
    rm google-chrome*.deb

    # Download VS Code deb
    wget https://go.microsoft.com/fwlink/?LinkID=760868 -O VS_Code.deb
    sudo dpkg -i VS_Code.deb
    sudo apt-get -y install -f
    rm VS_Code.deb

    # Download Git Kraken deb
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb -O GitKraken.deb
    sudo dpkg -i GitKraken.deb
    sudo apt-get -y install -f
    rm GitKraken.deb
}

function installRubyMine {
    #Download and Install
    wget https://download.jetbrains.com/ruby/RubyMine-2017.1.3.tar.gz
    tar -xvf RubyMine-2017.1.3.tar.gz
    sudo cp -a RubyMine-2017.1.3/. /usr/local/bin/RubyMine-2017.1.3/
    rm RubyMine-2017.1.3.tar.gz
    rm -rf RubyMine-2017.1.3/

    # Add RubyMine To App Launcher
    echo '[Desktop Entry]
    Name=RubyMine
    Type=Application
    Exec=/usr/local/bin/RubyMine-2017.1.3/bin/rubymine.sh 
    Terminal=false
    Icon=/usr/local/bin/RubyMine-2017.1.3/bin/RMlogo.svg
    Comment=Launches RubyMine
    NoDisplay=false
    Categories=Development;IDE
    Name[en]=RubyMine.desktop' > /usr/share/applications/RubyMine.desktop
}

function addAppsToStartupApplications {
    # Make autostart Directory if Does not exist
    sudo mkdir -p ~/.config/autostart/

    # Stop Mouse Acceleration on Startup
    echo '[Desktop Entry]
    Type=Application
    Exec=xset m 00
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name[en_IN]=Stop Mouse Acceleration
    Name=Stop Mouse Acceleration
    Comment[en_IN]=Stops Mouse Acceleration
    Comment=Stops Mouse Acceleration' > ~/.config/autostart/stopMouseAccel.desktop

    # Add Plank to Autostart
    echo '[Desktop Entry]
    Name=Plank
    GenericName=Dock
    Comment=Stupidly simple.
    Categories=Utility;
    Type=Application
    Exec=plank 
    Icon=plank
    Terminal=false
    NoDisplay=false' > ~/.config/autostart/plank.desktop
}

function installGrubHoldshift {
    # Grub Holdshift
    git clone https://github.com/hobarrera/grub-holdshift.git
    sudo cp grub-holdshift/31_hold_shift /etc/grub.d/
    rm -rf grub-holdshift/

    # Update Grub
    echo 'GRUB_DEFAULT=saved
    GRUB_SAVEDEFAULT=true
    GRUB_HIDDEN_TIMEOUT_QUIET=true
    GRUB_TIMEOUT=0
    GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
    GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
    GRUB_CMDLINE_LINUX=""
    GRUB_FORCE_HIDDEN_MENU="true"' > /etc/default/grub
    sudo update-grub
}

function removeUnusedPackages {
    # Remove all unused packages
    sudo apt-get -y autoremove
}

function configure {
    # Change Grub Background color to Black, so when skipping grub, dont notice grub.
    sudo rm /usr/share/plymouth/themes/default.grub
    echo 'if background_color 0,0,0; then
        clear
    fi' > /usr/share/plymouth/themes/default.grub

    # Remove Gnome logo from login screen
    rm /usr/share/plymouth/ubuntu-gnome_logo.png

    # Update Plymouth and Grub
    sudo update-initramfs -u
    sudo update-grub

    # Plymouth always makes and Reports errors
    # This uses apport to stop that :)
    echo "/sbin/plymouthd" | sudo tee --append /etc/apport/blacklist.d/apport

    removePreinstalledGnomeExtensions
    installGnomeExtensions
    downloadIcons
}


function removePreinstalledGnomeExtensions {
    # Remove Preinstalled Gnome Extensions
    sudo rm -rf /usr/share/gnome-shell/extensions/*
    sudo rm -rf /usr/local/share/gnome-shell/extensions/*
}

function installGnomeExtensions {
    # Install gnome etension installer for
    sudo wget -O /usr/local/bin/gnomeshell-extension-manage "https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnomeshell-extension-manage"
    sudo chmod +x /usr/local/bin/gnomeshell-extension-manage

    # Install Extensions
    gnomeshell-extension-manage --install --extension-id 750 --system
    gnomeshell-extension-manage --install --extension-id 234 --system
    gnomeshell-extension-manage --install --extension-id 608 --system
    gnomeshell-extension-manage --install --extension-id 442 --system
    gnomeshell-extension-manage --install --extension-id 358 --system
    gnomeshell-extension-manage --install --extension-id 19 --system
    

    # Add Gnome-Extensions to gsettings
    currentDir=$pwd
    cd /usr/local/share/gnome-shell/extensions
    extensions=(*)
    cd $currentDir

    for dir in "${extensions[@]}"
    do  
        cd /usr/local/share/gnome-shell/extensions/$dir/
        echo $pwd
        gschemaFile=$(find -name "*.gschema.xml")
        if [ ! -z "$gschemaFile" ]; then
            sudo cp $gschemaFile /usr/share/glib-2.0/schemas/
        fi
    done
    cd $currentDir
    sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

    # Reload Gnome-shell
    sudo /etc/init.d/gdm3 force-reload
}

function downloadIcons { 
    # Apps Icon for Gnome Activities Configurator  
    wget https://storage.googleapis.com/material-icons/external-assets/v4/icons/svg/ic_apps_white_24px.svg
    sudo mv ic_apps_white_24px.svg /usr/local/share/gnome-shell/extensions/apps_icon.svg
} 

function addScriptToStartup {
    # Add This Script To Startup So rest of Configuration can be done after reboot
    echo '[Desktop Entry]
    Name=Ubuntu-Themeing-Install-Script
    Comment=Rest Of Configurations
    Categories=Utility;
    Type=Application
    Exec='${SCRIPTPATH}'/install.sh afterReboot
    Terminal=false
    NoDisplay=false' > ~/.config/autostart/Ubuntu-Themeing-Install-Script.desktop
}

function askForReboot {
    echo 
    echo "#####################################################"
    echo "#####################################################"
    echo "For the rest of the changes to apply, please reboot."
    echo 
    echo "Would you like to reboot now (y/n)?"
    echo -n "> "
    read reply
    
    if [ "$reply" = y -o "$reply" = Y ]
    then
        sudo reboot
    else
        echo 
        echo "################################"
        echo "###### Please Reboot Soon ######"
        echo "################################"
        sleep 5s
    fi 
}


##########################
###### After Reboot ######
##########################

function afterReboot {
        enableAllGnomeExtensions
        configureTerminal
        configureTheme
        removeScriptFromStartup
}

function enableAllGnomeExtensions {
    # Enable Gnome-Extensions on Startup
    currentDir=$pwd
    cd /usr/local/share/gnome-shell/extensions
    extensions=(*)
    cd $currentDir

    for dir in "${extensions[@]}"
    do
        gnome-shell-extension-tool -e $dir
    done
}

function configureTerminal {
    profile_name=$(gsettings get org.gnome.Terminal.ProfilesList default)
    profile_name=$(sed -e "s/^'//" -e "s/'$//" <<<"$profile_name")

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_name}/ use-theme-colors false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_name}/ use-theme-transparency false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_name}/ use-transparent-background true
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_name}/ visible-name Transparent
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_name}/ background-transparency-percent 22
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile_name}/ foreground-color 'rgb(255,255,255)'
}

function configureTheme {
    # Plank
    createAndAddDockItems
    gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ icon-size 70
    gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ zoom-enabled true
    gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ zoom-percent 120
    gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ theme 'Transparent'

    # General Gnome Stuff
    gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize,appmenu:'
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface gtk-theme "Xenlism-Minimalism"
    gsettings set org.gnome.desktop.interface icon-theme "Ardis-Icons"
    gsettings set org.gnome.shell.extensions.user-theme name Uranus-V0.0.2
    gsettings set org.gnome.desktop.interface text-scaling-factor 1.5

    # Gnome Extension Settings
    # Gno-Menu
    gsettings set org.gnome.shell.extensions.gnomenu hide-panel-apps true
    gsettings set org.gnome.shell.extensions.gnomenu hide-panel-view true
    gsettings set org.gnome.shell.extensions.gnomenu use-panel-menu-icon false

    # Activities Config
    gsettings set org.gnome.shell.extensions.activities-config activities-config-button-icon-path '/usr/local/share/gnome-shell/extensions/apps_icon.svg'
    gsettings set org.gnome.shell.extensions.activities-config activities-config-button-no-text true

    #Drop Down Terminal
    gsettings set org.zzrough.gs-extensions.drop-down-terminal foreground-color '#FFF'
    gsettings set org.zzrough.gs-extensions.drop-down-terminal transparency-level 80
}

function createAndAddDockItems {
    # Items to be added to Plank Dock
    declare -a itemsToPutInDock=("google-chrome" "gnome-terminal" "nautilus" "code" "RubyMine" "gnome-control-center")

    # Remove all current launchers from launchers folder
    rm -rf ~/.config/plank/dock1/launchers/*

    # Create Dockitems
    first="true"
    itemArrayString="["
    for ((i=0; i<${#itemsToPutInDock[@]}; i++));
    do
        # Create .dockitem
        echo '[PlankDockItemPreferences]
        Launcher=file:///usr/share/applications/'${itemsToPutInDock[$i]}'.desktop' > ~/.config/plank/dock1/launchers/${itemsToPutInDock[$i]}.dockitem

        # Add .dockitem to string array
        itemsToPutInDock[$i]="${itemsToPutInDock[$i]}.dockitem"
        if [ $first = true ]; then
            itemArrayString="${itemArrayString}'${itemsToPutInDock[$i]}'"
            first="false"
        else
            itemArrayString="${itemArrayString}, '${itemsToPutInDock[$i]}'"
        fi
    done
    itemArrayString="${itemArrayString}]"

    # Add Dockitems to Plank's dock-items
    gsettings set net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ dock-items "${itemArrayString}"
}

function removeScriptFromStartup {
    sudo rm ~/.config/autostart/Ubuntu-Themeing-Install-Script.desktop
}

if [[ $1 = 'afterReboot' ]]; then
    afterReboot
    exit 0
else
    beforeReboot
    askForReboot
    exit 0
fi
