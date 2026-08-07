# Aurora DX Install Notes

These notes describe the Phase 1 manual install path.

## Requirements

- Aurora DX on x86 hardware
- Network connection
- Firefox, either system-installed or Flatpak-installed
- `python3`
- `systemd --user`
- `just` (included with Aurora DX)

## Install

Clone the repository and run:

```bash
just digidisplay
```

The setup will:

- Check the current operating system
- Ask for the display URL
- Write `~/digidisplay.json`
- Prepare a dedicated Firefox profile
- Install a systemd user service
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
