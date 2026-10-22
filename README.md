# DigiDisplay

DigiDisplay turns an Aurora DX computer into a dedicated browser appliance. It covers three products:

- **Digital signage**: a screen that shows a website or slideshow all day.
- **Interactive terminals**: a touch screen people use, which resets itself when they walk away.
- **Secure workstations**: a locked-down app screen that each user logs into.

DigiDisplay is open core. This client is free (Apache 2.0). DigiDisplay cloud (managed configs, hosting, content) is the paid service. If a box breaks, buy a new box, plug it in, log in, and you're done.

## Profiles

A **profile** decides how the machine behaves. Pick one with the `profile` key.

- **`signage`**: kiosk, logs in automatically, no on-screen keyboard, never locks. See [docs/profiles/signage.md](docs/profiles/signage.md).
- **`terminal`**: everything signage does, plus an on-screen keyboard when a text field is touched, and the page returns home after 90 idle seconds. See [docs/profiles/terminal.md](docs/profiles/terminal.md).
- **`workstation`**: no automatic login; each person logs into Linux, then the app opens. The screen locks after 10 idle minutes. See [docs/profiles/workstation.md](docs/profiles/workstation.md).

## Quick start

On a fresh Aurora DX install, open a terminal:

```bash
cd ~
git clone https://github.com/undoLogic/digi-display.git digi-display
cd ~/digi-display
```

Then either log in to DigiDisplay cloud:

```bash
just login     # asks for your email and password, then downloads this device's config
just apply
```

or create a local config with no cloud account:

```bash
just init      # or: just init terminal / just init workstation
just apply
```

Run every `just` command from inside `~/digi-display`. These are separate from Aurora's own `ujust` commands.

## Configuration

Everything lives in one file in your home folder: `~/digidisplay.json`. On Aurora, home is `/var/home/<user>`, so with a user named `digidisplay` the full path is `/var/home/digidisplay/digidisplay.json`. A basic config needs three keys:

```json
{
  "profile": "signage",
  "mode": "cloud",
  "url": "https://www.digi-display.com/en/Pages/demoSlideshow"
}
```

### Advanced: overrides

The profile fills in every other setting. Any key you write in the file wins over the profile default. `just init --advanced` writes every available key so you can see and change them.

`just status` prints the final settings and where each one came from (`config`, `profile:<name>`, `mode:<name>`, or `default`).

All keys are listed in [docs/features/config-schema.md](docs/features/config-schema.md).

**Keep this file private.** After `just login` it contains the device token, and in local mode it can contain a deploy key. DigiDisplay sets the file and its backups to owner-only (600). Do not share or commit it.

## Cloud and local mode

**Mode** decides where the content comes from. Any profile can use either mode.

- **`cloud`**: Firefox opens a remote `url`. This is the default.
- **`local`**: the app runs in Docker on the box itself, so the screen keeps working without internet. Add the repository:

```json
{
  "profile": "signage",
  "mode": "local",
  "local": {
    "repository": "git@github.com:example/client-project.git"
  }
}
```

The app is cloned to `~/digidisplay-webroot` and started with its `dockerLinux/1startDocker.sh` script. It is only updated when you run `just update-app`. See [docs/features/local-runtime.md](docs/features/local-runtime.md).

## Secure workstations

Workstation users are normal Linux accounts without admin (sudo) rights. Create one per person:

```bash
sudo useradd -m alice
sudo passwd alice
```

Each user then logs in at the login screen, and the kiosk opens the app.

**Switching an existing signage or terminal device to a workstation: reflash and redeploy from scratch.** Settings such as automatic login are one-way; setting them to `false` does not undo them.

## Commands

| Command | What it does |
| --- | --- |
| `just init [profile] [--advanced]` | Create a local config (default profile: `signage`) |
| `just login` | Log in to DigiDisplay cloud, save the device token, then pull |
| `just pull` | Re-download this device's config. Overwrites local edits; the old file is kept in `~/digidisplay-backups/` |
| `just apply` | Make the device match the config, then (re)start the kiosk |
| `just status` | Show final settings, where each came from, and recent logs |
| `just update-app` | Local mode only: update the app from Git and restart it |
| `just launch` | Troubleshooting: run the kiosk in the foreground |
| `just cancel` | Troubleshooting: stop the kiosk and close Firefox |
| `just tailscale` | Optional: enable Tailscale remote access |

## Updating DigiDisplay itself

```bash
cd ~/digi-display
git pull
just apply
```

Your config (`~/digidisplay.json`) and backups (`~/digidisplay-backups/`) live in your home folder, outside the repository.

## Recovery

- **Wrong page or settings:** edit `~/digidisplay.json`, then `just apply`.
- **Start over with a fresh config:** `mkdir -p ~/digidisplay-backups && mv ~/digidisplay.json ~/digidisplay-backups/`, then `just init`.
- **Undo a pull:** copy a backup over the active file, then apply:

  ```bash
  ls ~/digidisplay-backups/
  cp ~/digidisplay-backups/digidisplay-2026_10_22_10_02_11.json ~/digidisplay.json
  just apply
  ```

- **Kiosk will not start:** `just status`, or `journalctl --user -u digidisplay.service -n 100 --no-pager`.
- **Stop the kiosk starting at login:** `systemctl --user disable --now digidisplay.service` (re-enable with `systemctl --user enable --now digidisplay.service`).
- **Remove automatic login:** `sudo rm -f /etc/plasmalogin.conf.d/digidisplay-autologin.conf /etc/sddm.conf.d/digidisplay-autologin.conf`, then reboot.
- **Screen turns off:** `just apply` sets Plasma's dim and screen-off settings to Never; check them in System Settings > Power Management.

## Documentation

Start at [docs/README.md](docs/README.md).

## License

Apache License 2.0. See `LICENSE` and `NOTICE`.





## Troubleshooting

### Trying to connect over RDP starting but failing
For the previous workaround, it should say NoNewPrivileges=no. yes means the restriction is still enabled.

Check to ensure disabled 
- If YES, means it is blocked
```shell
systemctl --user show app-org.kde.krdpserver.service -p NoNewPrivileges
```

Run these on the target Aurora computer:
TODO: This is not surviving a reboot right now
```shell


sudo mkdir -p /etc/systemd/user/app-org.kde.krdpserver.service.d

printf '[Service]\nNoNewPrivileges=false\n' |
  sudo tee /etc/systemd/user/app-org.kde.krdpserver.service.d/override.conf

systemctl --user daemon-reload
systemctl --user restart app-org.kde.krdpserver.service

systemctl --user show app-org.kde.krdpserver.service -p NoNewPrivileges

Once it reports no, try RDP again.
```