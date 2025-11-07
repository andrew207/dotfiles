# dotfiles
just my dotfiles to make reinstalling easier

also some post-install stuff

### Network
```
pacman -S networkmanager network-manager-applet
systemctl enable NetworkManager
```

### hyprland 
```
pacman -S hyprland xdg-desktop-portal-hyprland wayland-protocols qt5-wayland qt6-wayland
```

also sddm as the display manager<br>
```
pacman -S sddm
systemctl enable sddm
```

and autostart

```
mkdir -p /etc/sddm.conf.d
nano /etc/sddm.conf.d/10-hyprland.conf
```

contents:

```
[Autologin]
User=andrew
Session=hyprland.desktop

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell
```

and loginctl, just double check it's good...

```
systemctl status systemd-logind
```

### apps
``` 
pacman -S yay vlc firefox code proton-vpn-gtk-app foot fuzzel cliphist rofi grim tesseract steam transmission
```

* yay = aur downloader
* vlc = media player
* firefox = browser
* code = visual studio code
* proton-vpn-gtk-app = frontend app from protonvpn
* foot = terminal
* fuzzel = popup box thing
* cliphist = clipboard history thing that goes well with popup box thing
* rofi = start menu
* grim = screenshots
* tesseract = optical character recognition
* steam = gamer
* transmission = linux isos

### from yay
* google-chrome = work web browser
* roboto-mono-nerd = font i like for code

## printing
* cups = Printing system with web-based config and IPP support. 
* cups-pdf = Virtual PDF printer
* sane = Scanner
* avahi = mDNS daemon for network discovery
* nss-mdns = enable .local hostname resolution system-wide

cups 
cups-pdf
sane
avahi
nss-mdns

### Configure local hostname resolution
`sudo nano /etc/nsswitch.conf`, find `hosts: ` line and change to:

```hosts: files mdns_minimal [NOTFOUND=return] mymachines resolve myhostname dns```

### Enable services

```
sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now cups.service
sudo systemctl enable --now cups-browsed.service  # For dynamic network printer queues
```

Stuff should be accessible over `http://localhost:631/printers`. 