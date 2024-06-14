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

## Format Computer with new bootable USB key
- After UNetbootin is complete you have a USB key that can boot with your hardware
- Insert the USB key into your machine you want to use and turn it on
- Press the key sequence to boot from the USB (You might have to check your BIOS settings)
- This will ERASE all data on this machine
- After the computer is formatted and has booted into Lubuntu OR NixOS you can now configure with Digi-Display

## Configure LXDE
You now have LXDE installed on either Lubuntu, and you are now ready
to configure to match the requirements to have the screen start automatically 
and load the digital screen from our servers. 

### Wi-Fi
Follow the instructions how to connect to your Wi-Fi network
https://www.digi-display.com/Pages/faqs

### Integrate Display Software
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

Change the computer name now

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



#### Prevent screen from going to sleep
Create an autostart script in Session Settings which will ensure the screen stays on
- Link to the file 'disable-dpms.sh'

####
Disable translations, manually click the translation icon in the address bar
and uncheck "always offer to translate"

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

### Virtual Box
If you are testing this on virtual box, you need to install "Guest Additions CD"
- Menu 'Devices' => "Insert Guest Additions CD Images" 
- Open Terminal
```shell
cd /media/COMPUTERNAME/CDNAME/
sudo ./VBoxLinuxAdditions.run
```
You will now have Copy and paste between
- ensure you also check the box in Virtual Box - Details - Settings - General - advanced - BOTH shared clipboard and drag and drop to bidirectional

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
The program gets installed in the init_digiDisplay.sh

Setup a password
```angular2html
x11vnc -storepasswd
```

Run one time
```shell
x11vnc -usepw -forever -display :0 &
# disown
```

Auto run at computer startup
Add a autostart script to Session options - 'vnc.sh'


### SSH
- This gets installed with the init_digiDisplay.sh

### Security
To ensure that only SSH connections are received over Tailscale, we are going to add firewall rules. 
This will ensure that only the tailescale0 network adapter is allowed to receive SSH and VNC traffic, and all other adapters will be blocked (eg Eth0 will NOT receive any SSH at all)

```shell
sudo ufw enable
sudo ufw allow in on tailscale0 to any port 22
sudo ufw deny to any port 22
sudo ufw allow in on tailscale0 to any port 5900
sudo ufw deny to any port 5900
sudo ufw status
```



### Snap Windows with OpenBox

Install
```angular2html
apt install wmctrl xdotool
```

Create a script which will move the window

```shell
#!/bin/bash
# Set your own with which xdotool to get path
BASE='/home/username/bin' 

# Get screen dimensions
SCREEN_WIDTH=$(/run/current-system/sw/bin/xdotool getdisplaygeometry | awk '{print>
SCREEN_HEIGHT=$(/run/current-system/sw/bin/xdotool getdisplaygeometry | awk '{prin>

# Function to snap window to left half of the screen
snap_left() {
  $BASE/wmctrl -r :ACTIVE: -e 0,0,0,$(( ($SCREEN_WIDTH / 3) * 2)),$SCREEN_HEIGHT ->
}

snap_right() {
  $BASE/wmctrl -r :ACTIVE: -e 0,$(( ($SCREEN_WIDTH / 3) * 2)),0,$(($SCREEN_WIDTH />
}

snap_top() {
  $BASE/wmctrl -r :ACTIVE: -e 0,0,0,$SCREEN_WIDTH,$(($SCREEN_HEIGHT))
}

snap_bottom() {
  $BASE/wmctrl -r :ACTIVE: -e 0,0,$(($SCREEN_HEIGHT / 2)),$SCREEN_WIDTH,$(($SCREEN>
}

case "$1" in
  left)
    snap_left
    ;;
  right)
    snap_right
    ;;
  top)
    snap_top
    ;;
  bottom)
    snap_bottom
    ;;
  *)
    echo "Usage: $0 {left|right|top|bottom}"
    exit 1
    ;;
esac


```

Modify the OpenBox keyboard bindings

```shell
nano ~/.config/openbox/rc.xml
```

```shell
<keyboard>
  <!-- Other existing key bindings -->
  
  <keybind key="W-Left">
    <action name="Execute">
      <command>~/snap_windows.sh left</command>
    </action>
  </keybind>
  
  <keybind key="W-Right">
    <action name="Execute">
      <command>~/snap_windows.sh right</command>
    </action>
  </keybind>
  
  <keybind key="W-Up">
    <action name="Execute">
      <command>~/snap_windows.sh top</command>
    </action>
  </keybind>
  
  <keybind key="W-Down">
    <action name="Execute">
      <command>~/snap_windows.sh bottom</command>
    </action>
  </keybind>
</keyboard>
```

After chaning we need to reload

```shell
openbox --reconfigure
```