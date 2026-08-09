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
just digidisplay-cancel
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

For local mode, the same log includes repository, Docker Compose, and health-check failures. The kiosk remains closed when the local health check fails. Correct the configuration or application problem, then run:

```bash
systemctl --user restart digidisplay.service
```

`just digidisplay-update` refuses to update a repository with tracked local changes. Resolve those changes in the configured project checkout before retrying.

## Remove Desktop Autologin

If setup enabled desktop autologin, remove the DigiDisplay drop-in file. Aurora's default login
manager is `plasmalogin`; older images may still use `sddm`:

```bash
sudo rm -f /etc/plasmalogin.conf.d/digidisplay-autologin.conf
sudo rm -f /etc/sddm.conf.d/digidisplay-autologin.conf
```

Then reboot.
