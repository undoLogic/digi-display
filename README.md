# Digi-Display: Custom Digital Display Solution

Our solution will allow to create a Digital Display with most computer hardware, even older outdated models. Follow the instructions 
and after connecting to your already prepared online URL with your display you can connect to any TV / Monitor in your business and display.
If you use our managed online solution to create the display materials www.Digi-Display.com you can change text and replace 
images without any HTML experience. Our company also offers fully managed computers that can be shipped to your office fully prepared to 
simply plug in and run your display.

Our solution uses the LXDE desktop environment. You can 
either install using the Lubuntu ISO or you can use NixOS to install. 

1. [Create bootable USB keys on Windows](#unetbootin-to-create-bootable-usb-keys-from-iso)
2. [Install with Lubuntu ISO](#install-with-nixos-iso)
3. [Install with NixOS](#install-with-nixos-iso)
4. [Format your computer with bootable USB key](#format-computer-with-new-bootable-usb-key)
5. [NixOS Preparation](#nixos-preparation-only)
6. [Configure LXDE](#configure-lxde)

## Unetbootin to create bootable USB keys from ISO

On windows install the program **UNetbootin** with Chocolatey.org
```angular2html
choco install unetbootin
```
Format the USB KEY
- WIN + E
- Right click on drive
- Format Quick and change label

## Install with Lubuntu ISO
Open UNetbootin
- Choose Lubuntu LTS
- OR if you have the ISO image on your computer choose and assign the correct USB KEY drive letter
- Click OK to begin !

## Install with NixOS ISO
First download the [Graphical ISO image](https://nixos.org/download/#nixos-iso) from the NixOS.org website.
Now we will use UNetbootin to choose the ISO and click OK to begin

## Format Computer with new bootable USB key
- After UNetbootin is complete you have a USB key that can boot with your hardware
- Insert the USB key into your machine you want to use and turn it on
- Press the key sequence to boot from the USB (You might have to check your BIOS settings)
- This will ERASE all data on this machine
- After the computer is formatted and has booted into Lubuntu OR NixOS you can now configure with Digi-Display


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







## Configure LXDE
You now have LXDE installed on either Lubuntu OR NixOS, and you are now ready
to configure to match the requirements to have the screen start automatically 
and load the digital screen from our servers. 

### Wi-Fi
Follow the instructions how to connect to your Wi-Fi network
https://www.digi-display.com/Pages/faqs

### Intergrate Display Software
- After you install the Linux system. This will download and prepare our software on the local computer
- open a browser and type:
```
http://get.digi-display.com
```
- This will download the init_digiDisplay.sh to ~/Downloads

- open terminal and give execute permissions
```angular2html
cd ~/Downloads
chmod +x init_digiDisplay.sh
./init_digiDisplay.sh
```
This will now install all the files to the ~/Desktop/digiDisplay

### Connect
- open ~/Desktop/digiDisplay/config.json
- url: Add the website url
- kiosk: true will make the website full screen false will make it windowed

### START SCREEN Manually
- open ~/Desktop/digiDisplay
- ./runDigiDisplay.sh (right click and choose open as program)

### Manual Config

Firefox suppress crash notification bar. 
Open Firefox and type **about:config** in the address bar
- Search for '**resume_from_crash**' and set to **FALSE**
- Search for **browser.startup.page** and set to **0**
- Search for **services.sync.prefs.sync.browser.startup.page** and set to **false**

Open LXQt Configuration Center
- Session Settings
  - Basic Settings
    - Ask for confirmation to leave session UNCHECK
  - Autostart
      - upgnotifier UNCHECK
      - XScreensaver UNCHECK 
      - ADD 
        - Name: DigiDisplay
        - Command: /home/USERNAME/Desktop/digiDisplay/runDigiDisplay.sh
        - Wait for system tray CHECK

Start menu
  - Leave
    - Reboot

The computer should reboot and automatically start the screen



#### Prevent screen from going to sleep (not working yet)
Open a terminal and type in the following commands:
```angular2html
gsettings set org.gnome.desktop.session idle-delay 0
systemctl mask suspend.target
```
- The second command will require an admin password

#### Change background image
Right-click on the desktop background and choose **Desktop Preferences**
- Tab: Background
- Wallpaper mode: Zoom the image to fill the entire screen
- Browser for image - ~/Desktop/digiDisplay/screen-loading-image.jpg
- Apply - OK

#### Hide Desktop Icons
- Right click 'hide desktop icons'

#### Hide bottom bar
- right click on bottom bar
- Configure panel
- auto-hide

### Testing & Troubleshooting
- Ensure download speed is sufficient (Firefox -> Google -> speed test)
  - 1 Mbps is slow and will cause lagging when loading content on the screen
    - Make sure your USB Wi-Fi dongle is connected in USB-3 
- Resolution is wrong
  - Start -> Monitor Settings
    - Set Desired Resolution

### Remote Management

#### Tailscale 
Using TailScale you can remotely manage your digital signage box
- Open a terminal and type
```angular2html
curl -fsSL https://tailscale.com/install.sh | sh
```
After installation you can type
```angular2html
sudo tailscale up
```
and you will get a link to copy into your browser and login to authenticate the connection with your tailscale

#### VNC

Install x11vnc
```angular2html
sudo apt install x11vnc
```
Setup a password
```angular2html
x11vnc -storepasswd
```
Run
```shell
x11vnc -usepw -forever -display :0 &
# disown
```
Set as a service (not working)
```shell
sudo nano /etc/systemd/system/x11vnc.service
```

Paste this (not working)
```shell
[Unit]
Description=Start x11vnc at startup
After=display-manager.service

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -usepw -forever -display :0 -auth /home/digiDisplay/.Xauthority
ExecStop=/usr/bin/killall x11vnc
Restart=on-failure
User=digiDisplay

[Install]
WantedBy=multi-user.target
```

Enable the service
```shell
sudo systemctl enable x11vnc.service
sudo systemctl start x11vnc.service
```

Check the status
```shell
sudo systemctl status x11vnc.service
```

Reload service after changes
```shell
sudo systemctl daemon-reload
sudo systemctl enable x11vnc.service
sudo systemctl start x11vnc.service

```
Diagnose errors
```shell
nohup x11vnc -usepw -forever -display :0 -auth guess &
cat nohup.out
```
This will show you any errors

### SSH
- Not implemented yet