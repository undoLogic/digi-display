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
open ~/Desktop/digiDisplay/config.json
url: Add the website url
kiosk: true will make the website full screen false will make it windowed

### Configure WiFi
Follow the instructions how to connect to your WiFi network 
https://www.digi-display.com/Pages/faqs

### START SCREEN
open ~/Desktop/digiDisplay
./runDigiDisplay.sh

### Setup automatic opening screen on boot
Settings
- Startup Applications
- Add
- Name: runDigiDisplay
- Command -> Browse -> Desktop -> DigiDisplay -> runDigiDisplay.sh -> click OPEN
- Then click 'ADD'
- IMPORTANT: ensure you close all windows and do a graceful reboot to ensure the changes are persistent
- Reboot your computer and when it boots up the screen mode will automatically start up 
- Next unplug and replug to ensure it is setup to auto start after a power failure (adjust in bios if doesn't auto turn on)

### Disable popups
Since this is running in a public environment we don't want to see any popups
```php
sudo nano /etc/xdg/autostart/update-notifier.desktop
# Adjust setting
NoDisplay=true
```
