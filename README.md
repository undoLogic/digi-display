# Digi-Display: Custom Digital Display Solution

To prepare a new device
- After you install the new ubuntu system
- open a browser and type:
```
http://get.digi-display.com
```
- This will download the init_digiDisplay.sh to ~/Downloads

- open terminal and give execute permissions
```angular2html
cd ~/Downloads
chmod +x init_digiDisplay.sh
```

### Manual steps
Disable power settings to keep the screen running
- Settings
- Power
- Power mode PERFORMANCE
- Dim Screen UNCHECK
- Screen Blank OFF

### Configure
- open ~/Desktop/digiDisplay/config.json
- url: Add the website url
- kiosk: true will make the website full screen false will make it windowed

### Configure WiFi
Follow the instructions how to connect to your WiFi network 
https://www.digi-display.com/Pages/faqs

### START SCREEN
- open ~/Desktop/digiDisplay
- ./runDigiDisplay.sh (right click and choose open as program)

### Setup automatic opening screen on boot
Auto opens the full screen display after the computer has booted
- Search on ubuntu
- Startup Applications
- Add
- Name: runDigiDisplay
- Command -> Browse -> Desktop -> DigiDisplay -> runDigiDisplay.sh -> click OPEN
- Then click 'ADD'
- IMPORTANT: ensure you close all windows and do a graceful reboot to ensure the changes are persistent
- Reboot your computer and when it boots up the screen mode will automatically start up 
- Next unplug and replug to ensure it is setup to auto start after a power failure (adjust in bios if doesn't auto turn on)

### Disable popups
- software update -> updates tab: NEVER | notify me of a new Ubuntu version: NEVER
- Click clock: choose do not disturb
- Settings: I also set applications to OFF

### Power button for instant shutdown
By default when you press the power button it displays a prompt, which is annoying and requires to have the remote control, so we are going to change the default behaviour of the power button to initiate instant power off
- First set the default behaviour to nothing
```
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'
```
- Next we are going to create a power interface file
```
nano /etc/acpi/events/power
```
- Paste the following code into it
```
#!/bin/sh
event=button/power
action=/usr/bin/logger "ACPI_POWER_BTTN_TEST: %e"
action=/home/digi-display/Desktop/DigiDisplay/shutdown.sh
```
OPTIONAL: If you want to see if the button is actually activating you can tail the log
```
tail -f /var/log/syslog
```
Now let's restart the ACPI service
```
service acpid restart
```

### Prevent browser sessions
Prevent firefox from keeping a session which will mess up the loading process for the kiosk mode
- Options -> History -> Never remember history

### Change background image
Right click on the desktop background and choose Change Background Image
- Top: Add Picture
- Navigate to Home -> digiDisplay -> screen-loading-image.jpg
- Then choose to activate
