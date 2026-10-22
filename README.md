# DigiDisplay

DigiDisplay turns an Aurora DX workstation into a browser-based digital-signage appliance. It can display a remote website in cloud mode or run a Git-managed Docker Compose application locally.

## Install on Aurora DX

Open Terminal and make sure Git is available:

```bash
ujust aurora-cli
git --version
```

Clone this public repository:

```bash
cd ~
git clone https://github.com/undoLogic/digi-display.git digi-display
cd ~/digi-display
```

There is no interactive setup wizard. DigiDisplay reads all setup values from:

```text
~/digidisplay.json
```

## Get or create a configuration

For a cloud-managed group, download its configuration:

```bash
just digidisplay-pull 123
```

For an unassigned/default cloud configuration:

```bash
just digidisplay-pull
```

For a self-managed device that should not contact the Digi-Display server:

```bash
just digidisplay-init
```

`just digidisplay-init` copies the complete current template from `config/digidisplay.json.example`. Keep that template updated whenever a new configuration variable is added; new initializations will then include it automatically.

Review or edit the file before applying it:

```bash
nano ~/digidisplay.json
```

## Apply the configuration

From the repository, run:

```bash
just digidisplay-apply
```

This validates the JSON, configures the hostname and Aurora desktop settings, installs the Firefox profile and systemd user service, applies the configured SSH/RDP/autologin choices, and starts the kiosk. If `reboot_after_apply` is `true`, the device reboots after the other operations succeed.

Firefox must already be installed. The first Firefox start may require accepting its initial screen and closing old tabs before kiosk use.

## Pull backups

Pull downloads the new file before changing the active configuration. When `~/digidisplay.json` already exists, it is first renamed using the local date and time:

```text
~/digidisplay-2026_08_16_10_02_11.json
```

Backups are not automatically deleted. Two pulls in the same second may overwrite the backup sharing that timestamp.

The MVP pull currently disables TLS certificate verification because the certificate served for `site2.digi-display.com` does not match that hostname. This is temporary and should be removed after the server certificate is corrected.

To use a different endpoint or config path:

```bash
DIGIDISPLAY_CONFIG_ENDPOINT=https://example.test/configure just digidisplay-pull 123
DIGIDISPLAY_CONFIG=/path/device.json just digidisplay-apply
```

## Configuration

Cloud example:

```json
{
  "version": 1,
  "group_id": false,
  "hostname": "digidisplay-lobby",
  "mode": "cloud",
  "url": "https://www.digi-display.com/en/Pages/demoSlideshow",
  "kiosk": true,
  "wait_for_network": true,
  "restart_browser": true,
  "autologin": true,
  "reboot_after_apply": false,
  "hide_menu": true,
  "virtual_keyboard": {
    "always_show": false
  },
  "remote_admin": {
    "tailscale": false,
    "ssh": false,
    "rdp": false,
    "nomachine": false
  },
  "update": {
    "automatic": false
  }
}
```

`remote_admin.ssh`, `remote_admin.rdp`, and `autologin` currently have one-way behavior. `true` enables/configures the feature; `false` does not remove a feature that was enabled previously.

`hide_menu` defaults to `true`. When enabled, Aurora's bottom Plasma menu auto-hides and appears when the mouse reaches the bottom edge of the screen. Set it to `false` to keep the menu visible, then run `just digidisplay-apply`.

`group_id: false` means the device is unassigned or locally managed. A positive integer identifies the Digi-Display server group used to retrieve a managed configuration.

## Local runtime (Docker)

Local mode runs an application repository with Docker Compose. Docker ships with Aurora DX. If it is unavailable, switch to Aurora DX and add the current user to the Docker group:

```bash
ujust devmode
ujust dx-group
```

Log out and back in after changing Docker-group membership, then confirm:

```bash
docker --version
docker compose version
```

Local example:

```json
{
  "version": 1,
  "group_id": false,
  "hostname": "digidisplay-local",
  "mode": "local",
  "url": "http://localhost",
  "kiosk": true,
  "wait_for_network": false,
  "restart_browser": true,
  "autologin": true,
  "reboot_after_apply": false,
  "hide_menu": true,
  "virtual_keyboard": {
    "always_show": false
  },
  "remote_admin": {
    "tailscale": false,
    "ssh": false,
    "rdp": false,
    "nomachine": false
  },
  "local": {
    "repository": "git@github.com:example/private-project.git",
    "branch": "main",
    "project_path": "~/DigiDisplay/projects/client-project",
    "docker_path": "docker-wsl",
    "ssh_key": "~/.ssh/digidisplay",
    "health_url": "http://localhost/"
  },
  "update": {
    "automatic": false
  }
}
```

Top-level `url` is what Firefox opens. `local.health_url` is the application readiness check. `local.docker_path` is relative to `local.project_path`.

Private-key contents must not be placed in this file; `local.ssh_key` is only a path. For SSH repositories, connect to the Git host once as the DigiDisplay user so its host key is present in `~/.ssh/known_hosts`.

On launch, DigiDisplay clones a missing repository, starts Compose, waits for the health URL, and opens Firefox. Ordinary launch/apply never updates an existing checkout. Update it explicitly with:

```bash
just digidisplay-update
```

The update requires a clean fast-forward, recreates containers without deleting volumes, checks application health, and restarts the kiosk.

## Commands

```bash
just digidisplay-pull [group_id]
just digidisplay-init
just digidisplay-apply
just digidisplay-status
just digidisplay-cancel
just digidisplay-run
just digidisplay-launch
just digidisplay-update
just digidisplay-tailscale
just digidisplay-activate-rdp
just digidisplay-activate-ssh
```

- `digidisplay-pull` downloads a configuration and backs up the old local file.
- `digidisplay-init` creates a new `~/digidisplay.json` from the current configuration template. It will not overwrite an existing file.
- `digidisplay-apply` applies the local JSON and starts/restarts the kiosk.
- `digidisplay-status` shows config, service state, and recent logs.
- `digidisplay-cancel` stops the kiosk and closes Firefox.
- `digidisplay-run` starts the kiosk service from an SSH session.
- `digidisplay-launch` runs the kiosk in the foreground for troubleshooting.
- `digidisplay-update` explicitly updates a local-mode application.
- `digidisplay-tailscale` helps enable Tailscale separately.
- `digidisplay-activate-rdp` applies the KRDP SELinux/systemd fix directly.
- `digidisplay-activate-ssh` enables the SSH server directly.

## Updating DigiDisplay itself

```bash
cd ~/digi-display
git pull
just digidisplay-apply
```

The active configuration and timestamped backups are stored outside the repository.

## Recovery

Restart the kiosk after a manual JSON edit:

```bash
just digidisplay-apply
```

Inspect status and logs:

```bash
just digidisplay-status
journalctl --user -u digidisplay.service -n 100 --no-pager
```

Restore a pull backup by copying the desired timestamped file over `~/digidisplay.json`, reviewing it, and applying it again.

## Files

```text
config/digidisplay.json.example
config/firefox/user.js
docs/features/digi-display-config-pull-apply-codex.md
docs/install/aurora-dx.md
docs/recovery/kiosk.md
scripts/digidisplay-apply
scripts/digidisplay-pull
scripts/digidisplay-activate-rdp
scripts/digidisplay-activate-ssh
scripts/digidisplay-cancel
scripts/digidisplay-init
scripts/digidisplay-launch
scripts/digidisplay-run
scripts/digidisplay-status
scripts/digidisplay-tailscale
scripts/digidisplay-update
scripts/lib/digidisplay-local-runtime
systemd/digidisplay-user.service
```

## Troubleshooting

If the screen keeps turning off, confirm Plasma's dim and turn-off settings are set to Never. `digidisplay-apply` attempts to set those values for AC, battery, and low-battery profiles.

If the virtual keyboard is not working, set `virtual_keyboard.always_show` to `true`, run `just digidisplay-apply`, and confirm Plasma Keyboard is installed and selected under System Settings → Keyboard → Virtual Keyboard.

## License

DigiDisplay is licensed under the Apache License 2.0. See `LICENSE` and `NOTICE`.
