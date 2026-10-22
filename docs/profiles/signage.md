# Profile: Digital Signage

**Status:** Implemented.

A screen nobody touches: menu boards, waiting rooms, lobby announcements. It powers on, logs in by itself, and shows the page all day.

## Defaults

Defined in `config/profiles/signage.json`. Any key written in `~/digidisplay.json` overrides these.

| Setting | Value | Meaning |
| --- | --- | --- |
| `kiosk` | `true` | Firefox full screen with no browser controls |
| `autologin` | `true` | Logs into the desktop without a password after boot |
| `restart_browser` | `true` | Firefox restarts if it closes |
| `hide_menu` | `true` | Aurora's bottom menu hides until the pointer reaches the bottom edge |
| `virtual_keyboard` | `off` | No on-screen keyboard |
| `idle_return` | `0` | Disabled: the page is never reset |
| `idle_lock_minutes` | `0` | Disabled: the screen never locks |

From the mode: `wait_for_network` is `true` in cloud mode and `false` in local mode.

## Minimal config

```json
{
  "profile": "signage",
  "mode": "cloud",
  "url": "https://www.digi-display.com/en/Pages/demoSlideshow"
}
```

## Testing

### Signage behaviour

**Intent:** A signage box shows its page unattended after every boot.

**Surfaces:**
- `config/profiles/signage.json`
- `just init`, `just apply`

#### Scenarios

- [ ] After `just init` and `just apply`, a reboot logs in automatically and opens the URL full screen.
- [ ] Closing Firefox reopens it within a few seconds.
- [ ] The screen does not dim, turn off, or lock after an hour idle.
- [ ] No on-screen keyboard appears.
- [ ] The URL opened has no `idle_return` parameter.
