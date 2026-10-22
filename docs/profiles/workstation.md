# Profile: Secure Workstation

**Status:** Implemented. Not launched as a product yet (waiting for customers).

A shared screen where each person logs in, then works only in the app. It locks when left alone, instead of resetting.

## Defaults

Defined in `config/profiles/workstation.json`. Any key written in `~/digidisplay.json` overrides these.

| Setting | Value | Meaning |
| --- | --- | --- |
| `kiosk` | `true` | Firefox full screen with no browser controls |
| `autologin` | `false` | Each user logs into Linux; then the kiosk opens the app |
| `restart_browser` | `true` | Firefox restarts if it closes |
| `hide_menu` | `true` | Aurora's bottom menu hides until the pointer reaches the bottom edge |
| `virtual_keyboard` | `on_touch` | On-screen keyboard on touch; a plugged-in keyboard also works |
| `idle_return` | `0` | Disabled: the page is not reset |
| `idle_lock_minutes` | `10` | The screen locks after 10 idle minutes |

From the mode: `wait_for_network` is `true` in cloud mode and `false` in local mode.

## Users

Users are local Linux accounts without sudo, created by hand:

```bash
sudo useradd -m alice
sudo passwd alice
```

Run `just apply` once as each user, from a clone of this repo in that user's home folder, so the kiosk service and settings exist for them.

## Converting an existing device

**Reflash and redeploy from scratch.** A device that ran signage or terminal has autologin configured, and `autologin: false` does not remove it. Applying the workstation profile on top would leave the box logging in without a password.

## Testing

### Workstation behaviour

**Intent:** Each person must log in, and an unattended screen locks.

**Surfaces:**
- `config/profiles/workstation.json`
- `scripts/digidisplay-apply` (`configure_kde_locking`)

#### Scenarios

- [ ] On a freshly flashed box, `just init workstation` then `just apply` and a reboot shows the login screen, not the desktop.
- [ ] After a user logs in, the kiosk opens the URL.
- [ ] After 10 idle minutes the screen locks and needs the user's password.
- [ ] Setting `"idle_lock_minutes": 2` locks after 2 minutes.
- [ ] A user created with `useradd` (no wheel group) cannot run `sudo`.
