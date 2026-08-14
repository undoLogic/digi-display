# Aurora DX Install Notes

These notes describe the manual cloud and local-mode install path.

## Requirements

- Aurora DX on x86 hardware
- Network connection
- Firefox, either system-installed or Flatpak-installed
- `python3`
- `systemd --user`
- `just` (included with Aurora DX)
- Local mode only: `git`, `curl`, Docker, and Docker Compose

## Install

Clone the repository and run:

```bash
just digidisplay
```

The setup will:

- Check the current operating system
- Ask for cloud or local deployment mode
- Ask for the display URL and local Git/Docker settings when applicable
- Write `~/digidisplay.json`
- Prepare a dedicated Firefox profile
- Install a systemd user service
- Set automatic display dimming and screen turn-off to Never for every power state
- Offer desktop autologin for the current user (sddm or plasmalogin, whichever is active)
- Offer to reboot

## Re-Run Setup

Run setup again to change kiosk options:

```bash
just digidisplay
```

Re-running setup updates the config and service file. It should not create duplicate services.

## Start Manually

For troubleshooting:

```bash
just digidisplay-launch
```

In local mode, the first launch clones the configured application if it is missing. Later launches use the existing checkout without pulling changes.

## Update A Local Application

```bash
just digidisplay-update
```

This is the only DigiDisplay command that fetches application code. It requires a clean checkout, performs a fast-forward update, recreates containers without deleting volumes, verifies the health URL, and restarts the kiosk.

## Check Status

```bash
just digidisplay-status
```

This shows the active config, service state, and recent logs.

## Tailscale

Remote access is opt-in.

After Tailscale is installed, run:

```bash
just digidisplay-tailscale
```

The command enables `tailscaled` and can run `sudo tailscale up`. It does not change firewall rules.
