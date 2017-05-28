# Ubuntu-Theming-Install-Script

This is meant for new installs of Ubuntu.
This script will automate the install of many useful apps and change your theme.

## Note
* This will change grub and plymouth
    * IF YOU HAVE DUALBOOT, HOLD SHIFT AFTER BIOS SCREEN TO SELECT OS TO BOOT FROM.
* This script uses and downloads from the following
    * [Gnome](https://www.gnome.org/)
    * [Xenlism-Minimalism](http://xenlism.github.io/minimalism/)
    * [Ardis Icon Theme](https://github.com/Nitrux/ardis-icon-theme.git)
    * [Uranus Shell Theme](https://www.gnome-look.org/content/show.php/Uranus?content=174476)
    * [Grub Holdshift](https://github.com/hobarrera/grub-holdshift.git)
    * [Plank](https://launchpad.net/plank)
    * [Google Chrome](https://www.google.com/chrome/)
    * [VS Code](https://code.visualstudio.com/)
    * [GitKraken](https://www.gitkraken.com/)
    * [RubyMine](https://www.jetbrains.com/ruby/)


## Install/Usage
1. Download and unzip, or clone from git repo.
2. Establish internet connection.
3. Run the install.sh script with sudo permissions.
4. `sudo ./install.sh`
    * When prompted for lightdm or gdm3 I recommend gdm3 as it looks better.
    * If you want to change it
        * `sudo apt-get install` gdm3 or lightdm
        * `sudo dpkg-reconfigure` gdm3 or lightdm
        * Reboot
        * `sudo apt-get remove` one you did not just install and reconfigure
5. To complete the install reboot needs to occur either when script prompts for reboot or after.
6. When brought to login screen, click the gear icon and select GNOME.
7. Login
8. Configuration completes.