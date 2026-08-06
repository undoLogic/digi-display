# DigiDisplay Recovery

Use these steps when a device does not start the kiosk or the wrong URL is shown.

## Change The URL

Open the visible config file in the home directory:

```text
~/digidisplay.json
```

Edit `url`, save the file, then restart the service:

```bash
systemctl --user restart digidisplay.service
```

## Stop The Kiosk

```bash
systemctl --user stop digidisplay.service
```

If Firefox is still open:

```bash
pkill -x firefox
```

## Disable Automatic Startup

```bash
systemctl --user disable --now digidisplay.service
```

## Re-Enable Automatic Startup

```bash
systemctl --user enable digidisplay.service
```

Then reboot or start it manually:

```bash
systemctl --user start digidisplay.service
```

## View Logs

```bash
journalctl --user -u digidisplay.service -n 100 --no-pager
```

## Remove SDDM Autologin

If setup enabled desktop autologin, remove the DigiDisplay SDDM file:

```bash
sudo rm /etc/sddm.conf.d/digidisplay-autologin.conf
```

Then reboot.
