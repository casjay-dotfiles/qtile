## qtile  
  
A full-featured, hackable tiling window manager written and configured in Python  
  
Automatic install/update:

```shell
bash -c "$(curl -LSs https://github.com/dfmgr/qtile/raw/master/install.sh)"
```

Manual install:
  
requires:

Debian based:

```shell
apt install qtile policykit-1-gnome xfce4-clipman-plugin xfce4-power-manager xfce4-notifyd volumeicon volumeicon-alsa scrot htop
```  

Fedora Based:

```shell
yum install qtile polkit-gnome xfce4-clipman-plugin xfce4-power-manager xfce4-notifyd volumeicon scrot htop
```  

Arch Based:

```shell
pacman -S qtile polkit-gnome xfce4-clipman-plugin xfce4-notifyd volumeicon scrot htop
```  

MacOS:  

```shell
brew install
```
  
```shell
mv -fv "$HOME/.config/qtile" "$HOME/.config/qtile.bak"
git clone https://github.com/dfmgr/qtile "$HOME/.config/qtile"
```
  
<p align=center>
  <a href="https://wiki.archlinux.org/index.php/qtile" target="_blank" rel="noopener noreferrer">qtile wiki</a>  |  
  <a href="http://qtile.org" target="_blank" rel="noopener noreferrer">qtile site</a>
</p>  
