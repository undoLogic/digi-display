# Aurora DX Install Notes

These notes describe the Phase 1 manual install path.

## Requirements

- Aurora DX on x86 hardware
- Network connection
- Firefox, either system-installed or Flatpak-installed
- `python3`
- `systemd --user`
- `ujust` or `just`

## Install

Clone the repository and run:

```bash
ujust digidisplay
```

The setup will:

- Check the current operating system
- Ask for the display URL
- Write `~/digidisplay.json`
- Prepare a dedicated Firefox profile
- Install a systemd user service
- Offer SDDM autologin for the current user
- Offer to reboot

## Re-Run Setup

Run setup again to change kiosk options:

```bash
ujust digidisplay
```

Re-running setup updates the config and service file. It should not create duplicate services.

## Start Manually

For troubleshooting:

```bash
ujust digidisplay-launch
```

## Check Status

```bash
ujust digidisplay-status
```

This shows the active config, service state, and recent logs.

## Tailscale

Remote access is opt-in.

After Tailscale is installed, run:

```bash
ujust digidisplay-tailscale
```

The command enables `tailscaled` and can run `sudo tailscale up`. It does not change firewall rules.
