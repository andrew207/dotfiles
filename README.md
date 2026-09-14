# dotfiles
just my dotfiles to make reinstalling and updating easier

also some post-install stuff

this readme was written in early 2025, back when hyprland had .conf files (now lua). 
also maybe printing is less terrible when you read this? here's hoping

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

### desktop shell

the bits hyprland itself leans on. these are what `apply.sh` writes config for, so install
them before running it.

```
pacman -S waybar swaync wallust cava playerctl pavucontrol nwg-look hypridle hyprlock wlogout
```

* waybar = the bar. config lives in `waybar/`, applied as a symlink to `configs/[TOP] Default`
* swaync = notification centre (the bell in the bar)
* wallust = generates `waybar/wallust/colors-waybar.css` from the wallpaper
* cava = audio visualiser feeding the bar's `custom/cava_mviz` module
* playerctl = media keys + the bar's now-playing module
* pavucontrol = volume mixer, opened by right-clicking the audio group
* nwg-look = gtk theme settings
* hypridle / hyprlock = idle timeout and lock screen, config in `hypr/`
* wlogout = the logout menu

### apps
``` 
pacman -S yay vlc firefox code proton-vpn-gtk-app foot fuzzel cliphist rofi grim slurp swappy wl-clipboard tesseract nautilus thunar mousepad steam transmission
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
* slurp = region picker, pipes into grim for snips
* swappy = annotate a snip before saving it
* wl-clipboard = `wl-copy`/`wl-paste`, needed by cliphist and the OCR keybind
* tesseract = optical character recognition
* nautilus = file manager (SUPER+E)
* thunar = other file manager (SUPER+ALT+E)
* mousepad = quick text editor (SUPER+ALT+C)
* steam = gamer
* transmission = linux isos

`pacman-q` in this repo is a full `pacman -Q` snapshot of the host, kept for reference.
`apply.sh` does not read or install from it.

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