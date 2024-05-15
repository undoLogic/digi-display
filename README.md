# Digi-Display: Custom Digital Display Solution

Our solution will allow to create a Digital Display with most computer hardware, even older outdated models. Follow the instructions 
and after connecting to your already prepared online URL with your display you can connect to any TV / Monitor in your business and display.
If you use our managed online solution to create the display materials www.Digi-Display.com you can change text and replace 
images without any HTML experience. Our company also offers fully managed computers that can be shipped to your office fully prepared to 
simply plug in and run your display.

### First create a bootable USB KEY
On windows install the program **UNetbootin** with Chocolatey.org
```angular2html
choco install unetbootin
```
Format the USB KEY
- WIN + E
- Right click on drive
- Format Quick and change label

Open UNetbootin
- Choose Lubuntu LTS
- OR if you have the ISO image on your computer choose and assign the correct USB KEY drive letter
- Click OK to begin !

### Image Created
- After UNetbootin is complete you have a USB key that can book with your hardware
- Insert the USB key into your machine you want to use as a Display display and turn it on
- Press the key sequence to book from the USB (You might have to check your BIOS settings)
- This will ERASE all data on this machine
- After the computer is formatted and has booted into Lubuntu you can now configure with Digi-Display

### Configure WiFi
Follow the instructions how to connect to your WiFi network
https://www.digi-display.com/Pages/faqs

### Installation
- After you install the new ubuntu system. This will download the neccessary files and auto upgrade the computer to the latest security updates
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

### Configure
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

#### Prevent screen from going to sleep
Open a terminal and type in the following commands:
```angular2html
gsettings set org.gnome.desktop.session idle-delay 0
systemctl mask suspend.target
```
- The second command will require a admin password



The computer should reboot and automatically start the screen

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

Install tightvnc
```angular2html
sudo apt update
sudo apt install tightvncserver
```
Now to configure
```angular2html
vncserver
```

