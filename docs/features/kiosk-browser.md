# Kiosk Browser and Desktop

**Status:** Implemented.

How `apply` and the kiosk service turn the Aurora desktop into a single-page appliance.

## Kiosk service

- `apply` installs `systemd/digidisplay-user.service` as the user service `digidisplay.service` and enables it, so the kiosk starts at login.
- The service runs `scripts/digidisplay-launch`, which waits for the graphical session, waits for the network if `wait_for_network` is true (up to 60 seconds, then starts anyway), prepares local mode if needed, closes any old Firefox, and opens the launch URL.
- `restart_browser: true` sets `Restart=always`, so a closed Firefox comes back within about 5 seconds.

## Firefox

- Uses its own profile (`~/.local/share/digidisplay/firefox-profile`, or the Flatpak equivalent) with the preferences in `config/firefox/user.js`: no first-run, session-restore, password or update prompts.
- `kiosk: true` opens with `--kiosk`. Firefox (system or Flatpak) must already be installed; the very first start may need its welcome screen accepted once.
- The launch URL is `url`, plus `idle_return=<seconds>` when `idle_return` is above 0.

## Desktop settings

| Setting | Effect |
| --- | --- |
| Power | Display never dims or turns off; no auto-suspend (AC, battery, low battery) |
| `idle_lock_minutes` | `0`: screen never locks. Above 0: locks after that many idle minutes and on resume |
| `hide_menu` | `true`: the bottom Plasma panel auto-hides. Needs one Plasma login before it can be set |
| `virtual_keyboard` | `off`: no input method. `on_touch`: Plasma Keyboard appears for text fields. `always`: always visible |
| `autologin` | Writes `digidisplay-autologin.conf` for plasmalogin or sddm, whichever is active |
| Wallpaper | `assets/wallpaper/digidisplay-wallpaper.jpg` |

`on_touch` and `always` need Plasma Keyboard (`/usr/share/applications/org.kde.plasma.keyboard.desktop`); without it apply prints a warning and skips the keyboard.

## Troubleshooting commands

- `just launch` runs the kiosk in the foreground, printing its output.
- `just cancel` stops the service and closes every Firefox process.

## Testing

### Kiosk and desktop

**Intent:** The desktop behaves like an appliance and the browser always comes back.

**Surfaces:**
- `scripts/digidisplay-launch`, `scripts/digidisplay-apply`
- `systemd/digidisplay-user.service`, `config/firefox/user.js`

#### Scenarios

- [ ] After `apply`, the kiosk opens without Firefox welcome, restore or password prompts.
- [ ] `"kiosk": false` opens a normal Firefox window.
- [ ] `"restart_browser": false` leaves Firefox closed after it is closed.
- [ ] `"hide_menu": false` keeps the bottom panel visible after apply.
- [ ] `"virtual_keyboard": "always"` shows the keyboard all the time; `"off"` never shows it.
- [ ] `just cancel` closes the kiosk; `just launch` reopens it in the foreground.
- [ ] With the network down at boot and `wait_for_network` true, Firefox still opens after about 60 seconds.
