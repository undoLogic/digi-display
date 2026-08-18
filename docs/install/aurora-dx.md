# Aurora DX install notes

These notes describe the cloud and local-mode MVP install path.

## Requirements

- Aurora DX on x86 hardware
- Network connection
- Firefox, either system-installed or Flatpak-installed
- `python3`
- `systemd --user`
- `just` (included with Aurora DX)
- Local mode only: `git`, `curl`, Docker, and Docker Compose

## Install the repository

```bash
cd ~
git clone https://github.com/undoLogic/digi-display.git digi-display
cd ~/digi-display
```

There is no interactive setup. All settings come from `~/digidisplay.json`.

## Get a configuration

Pull the default/unassigned configuration:

```bash
just digidisplay-pull
```

Or pull a managed group:

```bash
just digidisplay-pull 123
```

For a device that should not contact the Digi-Display server, copy the example:

```bash
just digidisplay-init
```

Review the JSON:

```bash
nano ~/digidisplay.json
```

## Apply

```bash
just digidisplay-apply
```

Apply validates the file, configures the Aurora desktop and hostname, installs the Firefox profile and systemd user service, applies enabled SSH/RDP/autologin settings, and starts the kiosk. Set `reboot_after_apply` to `true` when apply should reboot after completing successfully.

The example configuration hides Aurora's bottom Plasma menu by default. Move the mouse to the bottom edge of the screen to reveal it. Set `hide_menu` to `false` if the menu should remain visible, then run `just digidisplay-apply` again.

Re-run `just digidisplay-apply` after changing setup values in the JSON.

## Start manually

For foreground troubleshooting:

```bash
just digidisplay-launch
```

In local mode, the first launch clones the configured application if it is missing. Later launches use the existing checkout without pulling changes.

## Update a local application

```bash
just digidisplay-update
```

This is the only DigiDisplay command that fetches application code. It requires a clean checkout, performs a fast-forward update, recreates containers without deleting volumes, verifies the health URL, and restarts the kiosk.

## Check status

```bash
just digidisplay-status
```

This shows the active config, service state, and recent logs.

## Tailscale

Tailscale remains opt-in and separate from config pull/apply:

```bash
just digidisplay-tailscale
```
