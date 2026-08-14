# DigiDisplay

DigiDisplay turns an Aurora DX workstation into a browser-based digital signage appliance. It can display a remote website in cloud mode or run a Git-managed Docker Compose application locally for offline operation.

## Quick Start

Install Aurora DX, connect networking, open Terminal, and clone this public GitHub repository:

```bash
ujust aurora-cli
```
NOTE: The valkerie error appears to be the newer method from brew, so you can accept it.

Confirm Git is available, then clone the repository:

Install the Digi-Display files to the local computer
- Because the repository is public, GitHub authentication is not required for cloning it.
```bash
git --version
cd ~
git clone https://github.com/undoLogic/digi-display.git digi-display
cd ~/digi-display
```

```bash
just digidisplay
```

The setup asks all the questions to configure the system
- If you want to manually adjust the configuration file you can do so at: 

```text
~/digidisplay.json
```

Cloud mode uses the following URL by default:

```text
https://www.undologic.com/en/pages/screen
```

After setup, reboot the device. Firefox should open automatically in kiosk mode.

## Manual steps
- First firefox start you need to click continue
- Then close and reopen and you need to close the open previous tabs

The setup automatically sets **Dim automatically** and **Turn off screen** to **Never** for AC, battery, and low-battery power states.

## Local Runtime (Docker)

Local mode runs a configured application repository with Docker Compose. Docker ships with Aurora DX; if it is not yet available, switch to Aurora DX with:

```bash
ujust devmode
```

This rebases the system to Aurora DX and reboots. After it completes, run:

```bash
ujust dx-group
```

This adds the current user to the `docker` group so Docker can run without `sudo`. Log out and back in for the group change to take effect, then confirm Docker is available:

```bash
docker --version
docker compose version
```

Run `just digidisplay` and select `local`. Setup asks for the Git repository, branch, deployment path, Compose directory, optional SSH deploy key, health URL, and browser URL. On launch, DigiDisplay clones a missing repository, starts Compose, waits for the health URL, and then opens Firefox.

Ordinary launches never fetch or pull an existing local repository. Application code changes only when an administrator runs:

```bash
just digidisplay-update
```

The update must be a clean fast-forward. It recreates containers without deleting volumes, checks application health, and restarts the kiosk.

## Update an Existing Installation

To download the latest version of the project later:

```bash
cd ~/digi-display
git pull
just digidisplay
```

The local display configuration in `~/digidisplay.json` is not stored in the repository and can be edited independently.

## Commands

```bash
just digidisplay
just digidisplay-status
just digidisplay-cancel
just digidisplay-run
just digidisplay-launch
just digidisplay-update
just digidisplay-tailscale
just digidisplay-activate-rdp
just digidisplay-activate-ssh
```

`just digidisplay` configures the kiosk.

`just digidisplay-status` shows the config, systemd user service state, and recent service logs.

`just digidisplay-cancel` stops the kiosk service and kills Firefox if it is still running, logging whether it had to do so — useful confirmation when run over SSH.

`just digidisplay-run` starts the kiosk service (the opposite of `digidisplay-cancel`). Meant to be run over SSH: it starts `digidisplay.service` via `systemctl --user`, so Firefox opens on the physical display, not the SSH session.

`just digidisplay-launch` starts the kiosk manually in the foreground for troubleshooting.

`just digidisplay-update` explicitly updates and restarts a configured local-mode application.

`just digidisplay-tailscale` helps enable Tailscale after it is installed.

`just digidisplay-activate-rdp` fixes KRDP login failing right after credentials are entered, caused by an SELinux/`NoNewPrivileges` conflict on ostree-based images. This is also offered as a setup question during `just digidisplay`.

`just digidisplay-activate-ssh` enables and starts `sshd.service` for remote maintenance access (`ssh user@host`). This is also offered as a setup question during `just digidisplay`, and the choice is recorded in `remote_admin.ssh`.

`just digidisplay` also asks for a hostname, applied via `hostnamectl` so the device is identifiable on the network.

## Configuration

The active config is stored at:

```text
~/digidisplay.json
```

Example:

```json
{
  "version": 1,
  "hostname": "digidisplay-lobby",
  "mode": "cloud",
  "url": "https://www.undologic.com/en/pages/screen",
  "kiosk": true,
  "wait_for_network": true,
  "restart_browser": true,
  "virtual_keyboard": {
    "always_show": false
  },
  "remote_admin": {
    "tailscale": false,
    "ssh": false,
    "nomachine": false
  },
  "update": {
    "automatic": false
  }
}
```

Local mode adds a `local` object:

```json
{
  "version": 1,
  "mode": "local",
  "url": "http://localhost",
  "kiosk": true,
  "wait_for_network": false,
  "restart_browser": true,
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

Private key contents must not be placed in this file; `ssh_key` is only a path. Edit the configuration, then reboot or restart the user service:

```bash
systemctl --user restart digidisplay.service
```

For SSH repositories, connect to the Git host once as the DigiDisplay user before unattended startup so its host key is present in `~/.ssh/known_hosts`.

## Files

```text
config/digidisplay.json.example
config/firefox/user.js
docs/features/aurora-ujust.md
docs/install/aurora-dx.md
docs/recovery/kiosk.md
scripts/digidisplay-activate-rdp
scripts/digidisplay-activate-ssh
scripts/digidisplay-bootstrap
scripts/digidisplay-cancel
scripts/digidisplay-launch
scripts/digidisplay-run
scripts/digidisplay-status
scripts/digidisplay-tailscale
scripts/digidisplay-update
scripts/lib/digidisplay-local-runtime
systemd/digidisplay-user.service
tests/digidisplay-runtime-test
```

## License

DigiDisplay is licensed under the Apache License 2.0. See `LICENSE` and `NOTICE`.





## Troubleshooting
The screen keeps turning off
- Ensure the "Dim Automatically" is set to never
- Also Ensure "Turn Off Screen" is set to never

The virtual keyboard is not working
- System Settings → Keyboard → Virtual Keyboard
- Select Plasma Keyboard. > Top right > Set Show Virtual Keyboard to With Touch, Tablet, and Mouse.
- Click Apply.

You can also rerun `just digidisplay` and enable the on-screen keyboard when prompted.
