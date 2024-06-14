The initial testing how NixOS can be used for this project - not working yet
3. [Install with NixOS](#install-with-nixos-iso)


## Install with NixOS ISO
First download the [Graphical ISO image](https://nixos.org/download/#nixos-iso) from the NixOS.org website.
Now we will use UNetbootin to choose the ISO and click OK to begin

## NixOS Preparation only
If you have chosen to proceed with NixOS you will need to add your NIX configuration file. NixOS will allow greater control over your box in the future.
```shell
cd /etc/nixos
sudo nano configuration.nix
```
Then paste in this file [configuration.nix](https://github.com/undoLogic/digi-display/blob/main/configuration.nix)
Click save
```shell
sudo nixos-rebuild switch
```





Monitor

BASE='/home/username/.nix-profile/bin'

```shell
nix-env -iA nixos.wmctrl nixos.xdotool

```