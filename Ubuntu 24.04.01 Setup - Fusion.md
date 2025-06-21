# Guide to setup up Ubuntu on VMWare Fusion

Check Ubuntu site to download the latest server version of Ubuntu 24.04.01. Make sure you select the ARM64 version. There is no desktop version.

## VMWare Fusion Setup

1. Create a new VM - by either selecting the downloaded ISO or dragging it.
2. Select 8 GB RAM and at least 50 GB Disk Space.
3. User Name = dev and Name = developer

>**TIP**: If your mouse is stuck in the guest window use CTRL + CMD (⌘) Key

## Setting up the base version for Ubuntu Server
Update and upgrade all packages before installing anything else
``` sh
sudo apt update && sudo apt upgrade -y
```
Install `micro`, `fish` and `wireguard`
``` sh
sudo apt install micro fish wireguard
```

Change the default shell to fish
``` sh
sudo -u $(logname) chsh -s $(which fish)
```

----
### Install GNOME Desktop
We will go with gnome as other desktops do not have ARM64 packages.

``` sh
sudo apt install ubuntu-desktop
```
>Tip: During install, choose GDM3 during install. LightDM has some issues. 

#### Install VM-Tools. This should take care of copy/paste from/to host/guest.

``` sh
sudo apt install open-vm-tools-desktop
```

#### Install nemo file manager. It's much better than the default one.
``` sh
sudo apt install nemo
```

### Resolve long boot time
There is issue with duplicate network `systemd-networkd-wait-online.service`  which takes over 2+ minutes to boot. So change default timeout from 2 min to 1 second. There are two options to resolve the issue. Both are essentially the same except the first option is a script file which will help reduce time taken to manually follow the steps in Option 2. 

#### Option 1
1. Copy the file [<u>*boot_time_fix.sh*</u>](boot_time_fix.sh) to desktop 
2. Make it executable `chmod +x ~/Desktop/boot_time_fix.sh`
3. Run it from terminal `~/Desktop/boot_time_fix.sh`

#### Option 2

First disable the service
``` sh
sudo systemctl disable systemd-networkd-wait-online
```
Open the file systemd-networkd-wait-online.service in usr lib
``` sh
sudo micro /lib/systemd/system/systemd-networkd-wait-online.service
```
Search for line  `/lib/systemd/system/systemd-networkd-wait-online.service` and then *`add --timeout=1`* to its end so it looks like `/lib/systemd/system/systemd-networkd-wait-online.service --timeout=1`

Save the file and reenable the service
``` sh
sudo systemctl enable systemd-networkd-wait-online
```
##### Reboot
``` sh
sudo reboot
```
----
### Software Installs
Install other necessary software packages

#### Install snap packages

``` sh
sudo apt install snap-store −−channel=latest/stable/ubuntu-24.04
```

#### Visual Studio Code
Install VS Code by following directions on the site [https://code.visualstudio.com/docs/setup/linux](https://code.visualstudio.com/docs/setup/linux)

#### Install gnome-tweaks

``` sh
sudo apt install gnome-tweaks 
```

#### Calibre, Terminator

``` sh
sudo apt install calibre
```

#### Terminator (Optional)

``` sh
sudo apt install terminator
```

----
### Share folders between VMWare Fusion host and guest
>Remember to select folder from host in Fusion settings.

1. Create a folder on guest (Ubuntu) if required
    
    ``` sh
    sudo mkdir /mnt/hgfs/SharedWithVM
    ```
2. For the shared folder to load after reboots, modify `/etc/fstab`:

    Edit `/etc/fstab` and add the following line to the file:

    ``` sh
    vmhgfs-fuse /mnt/hgfs fuse defaults,allow_other,_netdev 0 0
    ```
    >Tip: The words need to be seperated by a tab.

    >NOTE: If you get error about permissions, you may need to run the following command
    ``` sh
    sudo chown -R $USER /mnt/hgfs/SharedWithVM
    ```

----

### Add alias for fish
#### Add alias for getting local IP to *fish shell*
``` sh
alias mylocalip="hostname -I"
```
#### Add alias for getting public IP to *fish shell*

``` sh
alias myip="dig +short txt ch whoami.cloudflare @1.0.0.1"
```

#### Install & Configure Wireguard VPN
Make sure you can load the shared folder first. You can confirm by using this command
``` sh
sudo ll /mnt/hgfs/SharedWithVM
```

Add add script to bypass sudo for our command

``` sh
sudo micro /etc/sudoers.d/mysudoer
```
Paste the following in the file and save it
```
# this file will contain my personal commands bypass sudo, this one is for wireguard
developer ALL = (root) NOPASSWD: /usr/bin/wg-quick
```
Copy required folders from Share Folder to Documents
``` sh
cp -r /mnt/hgfs/SharedWithVM/Scripts ~/Documents/.
cp -r /mnt/hgfs/share/SharedWithVM/WG-Ubuntu ~/Documents/.
```

Copy the conf files to /etc/wireguard folder
``` sh
sudo cp ~/Documents/WG-Ubuntu/*.conf /etc/wireguard/.
```
Copy the service file to `/etc/systemd/system/`

``` sh
sudo cp ~/Documents/Scripts/startVPN.service /etc/systemd/system/.
```
Make the startvpn.sh as executable
``` sh
chmod +x ~/Documents/Scripts/startvpn.sh
```
Enable the service & start the service
``` sh
sudo systemctl enable /etc/systemd/system/startVPN.service 
sudo systemctl start startVPN.service
```
Check if VPN is working
``` sh
curl ipinfo.io
```

#### Autokey (optional)
This is similar to Keyboard Maestro on Mac or better still AutoHotKey on Windows.
Follow instructions on https://github.com/autokey/autokey/wiki/Installing#debian-and-derivatives 

After you obtained the Debian packages, open a terminal at the directory containing the packages and use the following commands to install the packages:
``` sh
VERSION="0.96.0"    # substitute with the version you downloaded
sudo dpkg --install autokey-common_${VERSION}_all.deb autokey-gtk_${VERSION}_all.deb
sudo apt --fix-broken install
```

### Other stuff
Here are some other things to add to make it easier to use.

#### Add following extensions to VS Code
1. Code Spell Checker by Street Side Software
2. WordCounter by Etienne Faisant
3. Markdown All in One (optional) by Yu Zhang

#### Setup Git
Setup Git to download originals. 
>For password, get the fine-grained Personal Access Token from password manager
``` sh
git clone https://github.com/p400012/IAP.git
```
Add the following to git global config
``` sh
git config --global user.name "P R"
git config --global user.email ""
```

#### Setup Time Server - NTP

``` sh
sudo timedatectl set-ntp on
```


### Optional Stuff if required

#### Terminator size
1. Open Terminator, then adjust its window's size and position as desired.
2. In the Terminator window, in the command-line area, right-click then choose **Preferences**.
3. In the **Layouts** tab, expand the **Type / Name** list, select **Terminal1**, then click **Save**.
4. Exit the **Preferences** dialog, then close and re-open Terminator.

#### Terminator font spacing
1. Open Gnome **Tweaks**
2. Select **Fonts** in the left bar. 
3. In the *Preferred Fonts* section make sure *Monospace Text* is set to a Monospace font. For example `Ubuntu Sans Mono Regular`. 
>Tip: When you click to select the fonts, there is a dropdown where you can filter fonts by Monospace.

#### Add `plank` to startup apps (only if plank is installed)
1. Open Gnome **Tweaks**
2. Select **Startup Applications** in the left bar.
3. Click on the **+** sign to add any app that you want to run after login


## Make it look like Mac
To change the look and feel of Ubuntu so that it looks like Mac OS follow these steps.

### Change to Dock
1. Open Settings and go to 