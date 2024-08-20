# Guide to setup up Ubuntu on UTM

Check Ubuntu site to download the latest server version of Ubuntu 24.04.01. Make sure you select the ARM64 version. There is no desktop version.

## UTM Setup

1. Create a new VM - use Apple Virtualization
2. Select the ISO you downloaded from Ubuntu site to create the VM
3. Select 8 GB RAM and 128 GB Disk Space.

>Tips: You can change the logo by selecting custom while editing the VM

## Setting up the base version for Ubuntu Server
Update and upgrade all packages before installing anything else
``` sh
sudo apt update && sudo apt upgrade -y
```
Install `micro` and `fish`
``` sh
sudo apt install micro fish
```
Change the default shell to fish
``` sh
sudo -u $(logname) chsh -s $(which fish)
```

### Share folders between UTM host and guest
>Remember to select ***VirtFS*** in UTM settings.
1. Install the following, not sure if all is required but just install it
``` sh
sudo apt install spice-vdagent qemu-guest-agent spice-webdavd
```
2. Create a folder on guest (Ubuntu) 
    
    ``` sh
    sudo mkdir /media/share
    ```
3. For the shared folder to load after reboots, modify `/etc/fstab`. Depending on Apple or QEMU virtualization the command for temperory mounting of shared folder and permanent mounting are different. See below:

    a. <u>Apple Virtualization</u>
    ``` sh
    sudo mount -t virtiofs share /media/share
    ```
    To ensure it the folder share sticks after reboot, add the `share	/media/share	virtiofs	rw,nofail	0	0` to `/etc/fstab`.
    >Tips: The words need to be seperated by a tab.

    b. <u>Using QEMU Virtualization</u>
    >Note: if using QEMU using VirtFS - make sure the folder name on MAC matches the one on guest VM
    ``` sh
    sudo mount -t 9p -o trans=virtio share /media/SharedWithVM -oversion=9p2000.L
    ```
    To ensure it the folder share sticks after reboot, add the `share	/media/SharedWithVM	9p	trans=virtio,version=9p2000.L,rw,_netdev,nofail	0	0` to `/etc/fstab`.
    >Tip: The words need to be seperated by a tab.

>NOTE: If you get error about permissions, you may need to run the following command
``` sh
sudo chown -R $USER /media/SharedWithVM
```

## Desktop Install
Install Budgie Desktop
``` sh
sudo apt install budgie-desktop-environment
```
>Tip: Choose GDM3 during install. LightDM has some issues. 

### Software Installs
Install the necessary softwares

#### Visual Studio Code
Install VS Code by following directions on the site [https://code.visualstudio.com/docs/setup/linux](https://code.visualstudio.com/docs/setup/linux)


#### Wireguard

``` sh
sudo apt install wireguard
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
#### Firefox, Thunderbird, Calibre

``` sh
sudo apt install firefox thunderbird calibre
```

#### Install plank and gnome tweaks

``` sh
sudo apt install plank gnome-tweaks 
```




### Other tweaks
Here are some other tweaks to make it usable

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

#### Swap WIN with CTRL
1. Open Gnome **Tweaks**
2. Select **Keyboard** in the left bar.
3. In *Layout* section, open **Additional Layout Options**.
4. Expand **Ctrl position** and select **Swap Left Win with Left Ctrl**

#### Add `plank` to startup apps
1. Open Gnome **Tweaks**
2. Select **Startup Applications** in the left bar.
3. Click on the **+** sign to add any app that you want to run after login

#### Add alias for getting local IP to *fish shell*

``` sh
alias mylocalip="hostname -I"
```
``` sh

```
``` sh

```
``` sh

```
``` sh

```
``` sh

```
``` sh

```