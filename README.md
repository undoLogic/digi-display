# OfflineBox: Custom Digital Display Solution

To prepare a new device
- After you install the new ubuntu system
- open a browser and type:
```
http://get.offlinebox.com
```
- This will download the 1-download.sh script called: get_offlinebox.sh



1-download.sh
- 

Config.json
- this is the overall settings file. Allows to setup the initial structure

cron-activate.sh
- This will ensure that run.sh is restarted if it stops running

profile.json
- Config will download this file. This file will choose what the display shows. eg which site will be visualized. 

run.sh
- Check's in to UpdateCase.com
- some type of key here
- Send config.json
- get's profile.json
- run profile
- git clone files into sites/domain.com
- start up docker
- run firefox kiosk mode

