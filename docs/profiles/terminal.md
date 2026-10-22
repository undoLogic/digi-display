# Profile: Interactive Terminal

**Status:** Implemented. The idle reset itself must be built into the website (see Idle return).

A touch screen the public uses: building directories, product search, visitor check-in, wayfinding. It works like signage, plus touch typing and a reset when the visitor leaves.

## Defaults

Defined in `config/profiles/terminal.json`. Any key written in `~/digidisplay.json` overrides these.

| Setting | Value | Meaning |
| --- | --- | --- |
| `kiosk` | `true` | Firefox full screen with no browser controls |
| `autologin` | `true` | Logs into the desktop without a password after boot |
| `restart_browser` | `true` | Firefox restarts if it closes |
| `hide_menu` | `true` | Aurora's bottom menu hides until the pointer reaches the bottom edge |
| `virtual_keyboard` | `on_touch` | On-screen keyboard appears when a text field is touched |
| `idle_return` | `90` | Seconds of no input before the website returns home |
| `idle_lock_minutes` | `0` | Disabled: the screen never locks |

From the mode: `wait_for_network` is `true` in cloud mode and `false` in local mode.

## Idle return

DigiDisplay does not reset the page itself. It adds the setting to the URL Firefox opens:

```text
https://example.com/screen            ->  https://example.com/screen?idle_return=90
https://example.com/screen?lang=en    ->  https://example.com/screen?lang=en&idle_return=90
```

The website reads `idle_return` and, after that many seconds without input, goes back to its home page and clears anything typed. With `idle_return` set to `0` the parameter is left off.

## Keyboard and shortcuts

There is no shortcut lockdown. Aurora's on-screen keyboard has no Ctrl, Alt, Super or function keys, so visitors cannot leave the kiosk with it. A physical USB keyboard is the administrator's escape hatch.

## Testing

### Terminal behaviour

**Intent:** A public touch screen accepts typing and hands the website its idle timeout.

**Surfaces:**
- `config/profiles/terminal.json`
- `scripts/lib/digidisplay-config` (launch URL)
- `just init terminal`, `just apply`

#### Scenarios

- [ ] `just init terminal` then `just apply` opens the URL with `?idle_return=90` appended.
- [ ] A URL that already has a query string gets `&idle_return=90`.
- [ ] Setting `"idle_return": 30` in the config opens the URL with `idle_return=30`.
- [ ] Setting `"idle_return": 0` opens the URL with no `idle_return` parameter.
- [ ] Touching a text field shows the on-screen keyboard; touching elsewhere hides it.
- [ ] Everything in the signage checks also holds (autologin, restart, no screen lock).
