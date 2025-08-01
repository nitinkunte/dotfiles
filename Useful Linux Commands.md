# Useful Linux Commands
Instead of needing to search for these commands all the time, I decided to compile a list here. They are not in any particular order. I may categorize them if I find time later. 

## Find Existing Settings / Programs etc

### Display Manager
Display Manager provides graphical login screen at end of boot process and launches the next stage after login. 
> Examples: GDM, LightDM, SDDM etc

How to find current one?
``` sh
cat /etc/X11/default-display-manager
```

### Server (not sure what else to call it)
The X (X11) server handles the display and keyboard and mouse input. Wayland is the more modern replacement, but is a work-in-progress. 

How to find current one?
> if using fish shell
``` sh
bash -c 'loginctl show-session $(awk \'/tty/ {print $1}\' <(loginctl)) -p Type | awk -F= \'{print $2}\''
```
> if using bash shell
``` sh
loginctl show-session $(awk \'/tty/ {print $1}\' <(loginctl)) -p Type | awk -F= \'{print $2}\'
```
### Window Manager
The window manager handles the decoration and placement of windows. 
> Examples: Mutter, KWin, Compiz, Muffin.

How to find current one?
``` sh
wmctrl -m
```
> You may have to install wmctrl if it is not already there
``` sh
sudo apt-get install wmctrl
```
> *For some reason this command is not working. Try using `neofetch` or `screenfetch` as given below.

### Desktop Environment
A desktop environment is a collection of applications to work together. This will generally include a window manager, a default display manager, and a set of default applications. 
> Examples would be Gnome, KDE, Cinnamon, Xfce, Budgie etc

How to find current one?
``` sh
echo $XDG_CURRENT_DESKTOP
```

### All in one
You can install either `neofetch` or `screenfetch` or `fastfetch` which will provide all of the above information and more.

Neofetch
``` sh 
sudo apt install neofetch
```
Screenfetch
``` sh
sudo apt install screenfetch
```
fastfetch
``` sh
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
sudo apt update
sudo apt install fastfetch
```


## Find boot time issues
Use `systemd-analyze` to find the program that is delaying / causing longer boot time.

``` sh
systemd-analyze blame
```
OR
``` sh
systemd-analyze critical-chain
```

