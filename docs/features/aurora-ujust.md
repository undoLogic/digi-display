# DigiDisplay Aurora ujust Feature

Status: Draft for review

## Summary

DigiDisplay is an open-source digital signage appliance built on Aurora DX.

The first release should make one task simple and repeatable:

```bash
ujust digidisplay
```

After setup and reboot, the device should launch Firefox in kiosk mode and display a configured public URL. If no customer URL is entered, the setup should default to:

```text
https://www.digi-display.com/en
```

This project is not a slideshow editor, content management system, or media scheduling engine. It is the workstation bootstrap that turns a clean Aurora DX install into a professional browser-based kiosk.

## Product Position

DigiDisplay follows an open-core model.

The open-source project provides:

- Aurora DX workstation setup
- Firefox kiosk configuration
- Automatic browser startup
- Display power management settings
- DigiDisplay branding assets
- Documentation for installation and recovery
- Future hooks for Docker, local cache, and remote management

Commercial services can be built around it, including:

- UpdateCase CMS
- Managed hosting
- Remote monitoring
- Custom development
- Professional support
- Preconfigured hardware

The appliance software remains free. The managed services are commercial.

## Guiding Principle

Every feature should answer this question:

> Does this make it easier to turn an Aurora DX installation into a professional digital signage appliance?

If the answer is no, the feature belongs in another project.

## Phase 1 Scope

Phase 1 is an internet-connected kiosk.

It should:

- Confirm the system is running on Aurora DX or clearly warn when it is not
- Install or verify required packages
- Create a DigiDisplay configuration file
- Configure Firefox for unattended kiosk usage
- Configure automatic startup after login or reboot using a systemd user service
- Offer desktop autologin setup for appliance-style reboot behavior
- Prevent screen blanking and display sleep
- Launch a configured URL in Firefox kiosk mode
- Restart the browser if it is closed
- Provide clear manual recovery instructions

Phase 1 should not include:

- Docker
- Offline content hosting
- Media caching
- Scheduling
- Device registration
- User authentication
- CMS content editing
- Custom interactive terminal workflows

The browser is the appliance for Phase 1.

## Legacy Lessons

The old implementation proved several useful requirements:

- A simple JSON config is enough for the first URL and kiosk settings
- The display must not blank, sleep, or show a screensaver
- Firefox should be closed before starting a fresh kiosk session
- Startup should wait for basic network availability before opening the URL
- Remote administration is important, but it should be optional and documented
- Manual desktop setup is too fragile for repeatable deployments

The new implementation should keep those behaviors while replacing manual LXDE, NixOS, and desktop-click instructions with Aurora DX and `ujust`.

## Target User

Primary users:

- Installers preparing signage hardware
- Small businesses running menu boards, waiting-room screens, or announcement screens
- undoLogic staff deploying managed displays

The expected workflow should be:

1. Install Aurora DX on x86 hardware.
2. Connect networking.
3. Clone this repository.
4. Run `ujust digidisplay`.
5. Answer a few interactive setup questions.
6. Reboot.
7. The screen opens directly into the configured web display.

## Target Hardware

Primary target:

- x86 mini PCs
- x86 compute sticks
- NUC-style devices
- Repurposed desktop or laptop hardware connected to a TV or monitor

ARM support is out of scope until Aurora DX officially supports the target ARM hardware.

## Architecture

```text
Hardware
  -> Aurora DX
  -> DigiDisplay ujust recipe
  -> System/user startup configuration
  -> Firefox kiosk profile
  -> Public website or UpdateCase display URL
```

DigiDisplay is responsible for the local appliance setup. Website content remains outside this repository.

## Proposed Repository Structure

```text
README.md
LICENSE
NOTICE
justfile

assets/
  wallpaper/
  branding/

config/
  digidisplay.json.example
  firefox/

docs/
  features/
  install/
  recovery/

scripts/
  digidisplay-bootstrap
  digidisplay-launch
  digidisplay-status

systemd/
  digidisplay-user.service

future/
  docker/
```

The exact structure can change during implementation, but Phase 1 should keep runtime scripts separate from documentation and assets.

## Configuration

Phase 1 should use a visible local JSON config file directly in the installing user's home directory:

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

Initial rules:

- `url` defaults to `https://www.digi-display.com/en`
- `kiosk` defaults to `true`
- `wait_for_network` defaults to `true`
- `restart_browser` defaults to `true`
- Remote administration options default to disabled
- Re-running setup should preserve the existing URL unless the user chooses to change it

Secrets should not be stored in this file.

## Setup Prompts

`ujust digidisplay` should be interactive so it is easy to run directly on a new device.

The Phase 1 prompts should stay short:

- Display URL, defaulting to `https://www.digi-display.com/en`
- Confirm kiosk mode, defaulting to yes
- Confirm browser auto-restart, defaulting to yes
- Confirm desktop autologin, defaulting to yes
- Confirm whether to reboot now, defaulting to no

Non-interactive environment-variable support can be added later if automated fleet provisioning needs it.

## ujust Command

The main command should be:

```bash
ujust digidisplay
```

Responsibilities:

- Validate the current environment
- Confirm or collect the display URL
- Write the DigiDisplay config
- Install or verify required packages
- Install Firefox kiosk preferences
- Install and enable the systemd user service
- Offer SDDM autologin configuration for the current user
- Install branding assets
- Provide final reboot instructions

The command should be safe to run more than once. Re-running it should update the configuration without creating duplicate services or duplicate autostart entries.

Phase 1 should use a systemd user service as the primary launcher because it gives us restart behavior, logs, and a predictable status command. A desktop autostart entry should only be added later if Aurora DX testing proves the user service is not enough to start reliably after login.

Related commands:

```bash
ujust digidisplay
ujust digidisplay-status
ujust digidisplay-tailscale
```

`ujust digidisplay-tailscale` should be separate from the main setup so remote access stays opt-in.

## Firefox Behavior

Firefox should:

- Start full screen in kiosk mode
- Open the configured URL
- Avoid first-run prompts
- Avoid restore-session prompts
- Disable password saving prompts
- Disable telemetry prompts where practical
- Avoid update prompts where practical
- Relaunch automatically when closed

The kiosk should not rely on the user manually changing `about:config`.

## Display Behavior

The configured appliance should:

- Keep the monitor awake
- Disable screensaver behavior
- Disable DPMS blanking where supported
- Preserve the selected screen resolution
- Avoid visible desktop chrome during normal operation

If display power settings require user-specific desktop configuration, the implementation should document that clearly and keep the automated setup as complete as possible.

## Remote Administration

Remote administration is useful but should not be mandatory for Phase 1.

Supported documentation targets:

- SSH
- Tailscale
- NoMachine

Optional future targets:

- VNC
- Browser-based remote screenshot capture
- UpdateCase heartbeat and monitoring

Remote access should be documented with a security-first default: no public SSH/VNC listener should be enabled automatically.

Tailscale setup should be handled by a separate command:

```bash
ujust digidisplay-tailscale
```

That command should install or verify Tailscale, guide the user through authentication, and avoid changing firewall rules without clearly explaining what it is doing.

## Branding

DigiDisplay should identify itself without restricting customization.

Branding may include:

- Wallpaper
- Setup output
- About page
- Documentation
- Future boot splash

Customers and downstream users may replace these assets while preserving required Apache 2.0 license notices.

## Licensing

DigiDisplay is licensed under the Apache License 2.0.

Every distribution must preserve:

- Copyright notices
- License text
- NOTICE file

## Future Phases

### Phase 2: Offline Runtime

- Docker runtime
- Local web server
- Local media cache
- Synchronization with UpdateCase
- Graceful operation without internet

### Phase 3: Managed Fleet

- Device registration
- Heartbeats
- Screenshots
- Remote configuration
- Update reporting
- Basic health checks

### Phase 4: Interactive Terminal

Examples:

- Building directory
- Product search
- Employee lookup
- Hospital wayfinding
- Retail catalogue
- Visitor information

Additional requirements:

- On-screen keyboard
- Simplified input layout
- Restricted shortcut handling
- Touch-friendly navigation
- Admin unlock path for maintenance

## Acceptance Criteria

Phase 1 is complete when:

- A fresh Aurora DX device can run `ujust digidisplay`
- The setup command prompts for the key options
- The setup command writes a valid local config to `~/digidisplay.json`
- The configured URL launches in Firefox kiosk mode after reboot
- The default URL is `https://www.digi-display.com/en` when no customer URL is entered
- The setup offers desktop autologin so the kiosk can start after reboot without a manual login
- The display does not sleep or blank during normal operation
- Firefox relaunches automatically if closed
- Re-running setup does not duplicate systemd user services or startup entries
- The README documents install, configure, reboot, update, and recovery steps
- Remote admin options are documented but disabled by default
- Tailscale setup is available through `ujust digidisplay-tailscale`

## Decisions

- Local configuration lives directly in the user's home directory at `~/digidisplay.json`
- Phase 1 uses a systemd user service as the primary startup mechanism
- `ujust digidisplay` prompts interactively
- Desktop autologin is offered during setup and defaults to yes
- Tailscale setup is separate: `ujust digidisplay-tailscale`
- The starter URL is `https://www.digi-display.com/en`
