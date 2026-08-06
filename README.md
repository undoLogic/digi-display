# DigiDisplay

DigiDisplay turns an Aurora DX workstation into a browser-based digital signage appliance.

Phase 1 is intentionally simple: configure Firefox, start it in kiosk mode, keep the display awake, and load one public URL.

## Quick Start

Install Aurora DX, connect networking, open Terminal, and clone this public GitHub repository:

```bash
ujust aurora-cli
```

Confirm Git is available, then clone the repository:

```bash
git --version
cd ~
git clone https://github.com/undoLogic/digi-display.git digi-display
cd ~/digi-display
```

`ujust aurora-cli` installs Aurora's supported command-line tooling. If `git` is still unavailable, install it into the user environment with Homebrew:

```bash
brew install git
```

Because the repository is public, GitHub authentication is not required for cloning it.

From the repository root, run:

```bash
just digidisplay
```

The setup asks a few questions and writes the visible local config file:

```text
~/digidisplay.json
```

If no display URL is entered, DigiDisplay uses:

```text
https://www.digi-display.com/en
```

After setup, reboot the device. Firefox should open automatically in kiosk mode.

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
just digidisplay-launch
just digidisplay-tailscale
```

`just digidisplay` configures the kiosk.

`just digidisplay-status` shows the config, systemd user service state, and recent service logs.

`just digidisplay-launch` starts the kiosk manually for troubleshooting.

`just digidisplay-tailscale` helps enable Tailscale after it is installed.

## Configuration

The active config is stored at:

```text
~/digidisplay.json
```

Example:

```json
{
  "url": "https://www.digi-display.com/en",
  "kiosk": true,
  "wait_for_network": true,
  "restart_browser": true,
  "remote_admin": {
    "tailscale": false,
    "ssh": false,
    "nomachine": false
  }
}
```

Edit `url` to change the screen content. Reboot or restart the user service afterward:

```bash
systemctl --user restart digidisplay.service
```

## Files

```text
config/digidisplay.json.example
config/firefox/user.js
docs/features/aurora-ujust.md
docs/install/aurora-dx.md
docs/recovery/kiosk.md
scripts/digidisplay-bootstrap
scripts/digidisplay-launch
scripts/digidisplay-status
scripts/digidisplay-tailscale
systemd/digidisplay-user.service
```

## License

DigiDisplay is licensed under the Apache License 2.0. See `LICENSE` and `NOTICE`.
