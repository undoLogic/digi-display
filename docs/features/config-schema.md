# Config Schema

**Status:** Implemented.

All settings live in `~/digidisplay.json` (override the path with `DIGIDISPLAY_CONFIG`). `scripts/lib/digidisplay-config` is the only code that reads it; every other script uses its resolved values.

## Override rule

Settings are resolved in this order, and each step overrides the one before:

1. **default**: built-in values for keys no profile sets.
2. **profile**: `config/profiles/<profile>.json`.
3. **mode**: `url` and `wait_for_network` depend on `mode`.
4. **config**: every key written in `~/digidisplay.json`. A written key always wins.

`just status` prints each final value and which of these it came from.

## Keys

| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `profile` | `signage`, `terminal`, `workstation` | required | See `docs/profiles/` |
| `mode` | `cloud`, `local` | required | |
| `url` | http(s) URL | cloud: demo slideshow; local: `http://localhost` | The page Firefox opens; also the local readiness check |
| `hostname` | hostname | not set | Not set or `""`: the hostname is left unchanged |
| `kiosk` | true/false | profile | Firefox full screen, no browser controls |
| `autologin` | true/false | profile | One-way: `false` does not remove existing autologin |
| `restart_browser` | true/false | profile | Firefox restarts when it closes |
| `wait_for_network` | true/false | `true` in cloud, `false` in local | Wait up to 60 seconds for the network before opening Firefox |
| `hide_menu` | true/false | profile | Auto-hide Aurora's bottom menu |
| `virtual_keyboard` | `off`, `on_touch`, `always` | profile | |
| `idle_return` | whole seconds, `0` = off | profile | Added to the URL as `idle_return=<seconds>`; the website does the reset |
| `idle_lock_minutes` | whole minutes, `0` = off | profile | Lock the screen after this many idle minutes |
| `remote_admin.ssh` | true/false | `false` | One-way: enables the SSH server |
| `remote_admin.rdp` | true/false | `false` | One-way: installs the KRDP login fix |
| `reboot_after_apply` | true/false | `false` | Reboot when `apply` finishes successfully |
| `token` | string | not set | Device token written by `just login`; secret |
| `local.repository` | Git URL | required in local mode | |
| `local.branch` | string | `main` | |
| `local.deploy_key` | private key text | not set | Read-only deploy key for `local.repository`; secret |

Profile defaults are listed in each profile doc. Any other key is rejected, so a typo or a removed key stops `apply` with an error.

## Secrets in the file

As an intentional MVP shortcut, `token` and `local.deploy_key` are stored in the JSON. To limit the risk:

- `init`, `login`, `pull` and `apply` set the file and every backup in `~/digidisplay-backups/` to mode 600 (owner only), and the backup folder to 700.
- `just status` shows secrets only as `(set)` or `(not set)`.
- `pull` and `login` keep the token and password off the command line, so they do not appear in the process list.

Do not share, paste or commit the file.

## Removed keys

These keys from earlier versions are rejected: `version`, `group_id`, `update`, `virtual_keyboard.always_show`, `remote_admin.tailscale`, `remote_admin.nomachine`, `local.project_path`, `local.docker_path`, `local.ssh_key`, `local.health_url`. Recreate old configs with `just init` or `just login`.

## Testing

### Config resolution

**Intent:** Every setting has one predictable final value, and an explicit key always beats the profile.

**Surfaces:**
- `scripts/lib/digidisplay-config`
- `config/profiles/*.json`
- `just status`, `just init --advanced`

#### Scenarios

- [ ] A three-key config shows every other setting in `just status` with a `profile:` or `mode:` source.
- [ ] Adding `"autologin": false` to a signage config shows `autologin false` with source `config`.
- [ ] Cloud mode without `url` resolves to the demo slideshow; local mode without `url` resolves to `http://localhost`.
- [ ] `just init --advanced` writes every key in the table, and `just status` then shows them all as `config`.
- [ ] A config containing `version` or another unknown key makes `apply` stop with "Unknown key(s)".
- [ ] A missing or invalid `profile` or `mode` makes `apply` stop before changing anything.
- [ ] Local mode without `local.repository` makes `apply` stop with an error.
- [ ] `just status` never prints the token or deploy key.
