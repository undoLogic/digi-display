# DigiDisplay

## Vision

DigiDisplay is an open-source digital signage platform built on Aurora DX.

The goal is **not** to compete with traditional slideshow software.

The goal is to provide a secure, reproducible, immutable appliance that turns any x86 computer into a professional browser-based kiosk.

The project is intentionally open source because the value is not in the kiosk itself.

The value is in the ecosystem built around it.

---

# Business Model

DigiDisplay follows an open-core philosophy.

## Open Source

This repository provides:

- Aurora DX workstation configuration
- Firefox kiosk configuration
- Automatic startup
- Branding
- Docker (future)
- Documentation

Anyone is free to use, modify and extend DigiDisplay under the Apache 2.0 License.

---

## Commercial

undoLogic provides commercial services including:

- UpdateCase CMS
- Managed Hosting
- Remote Monitoring
- Custom Development
- Professional Support

The software is free.

The services are commercial.

---

# License

This project is licensed under the Apache License 2.0.

Every distribution must preserve:

- Copyright notices
- License text
- NOTICE file

See:

LICENSE

NOTICE

---

# Branding Philosophy

DigiDisplay should proudly identify itself.

Brand recognition should come from great software, not restrictive licensing.

Examples:

- DigiDisplay wallpaper
- DigiDisplay boot splash (future)
- DigiDisplay About page
- DigiDisplay documentation
- DigiDisplay website

The goal is for customers to know they are using DigiDisplay while remaining completely free to customize the platform.

---

# Vision

The long-term goal is to make deploying digital signage as simple as:

1. Install Aurora DX
2. Clone this repository
3. Run one command
4. Reboot

The device becomes a managed kiosk.

---

# Philosophy

- Open Source
- Built on Aurora DX
- Immutable Operating System
- Browser First
- Web Standards
- Security Through Simplicity

UpdateCase is the recommended CMS but is **not required**.

This repository is responsible for configuring the workstation.

It is **not** responsible for website content.

---

# Phase 1

Internet Connected Kiosk

- Boot directly into Firefox
- Launch Firefox in Kiosk Mode
- Display a configurable URL
- No Docker
- No local content
- No scheduling
- No authentication

The browser **is** the appliance.

---

# Phase 2

Offline Runtime

- Install Docker
- Local web server
- Local media cache
- Synchronize with UpdateCase
- Continue operating without Internet

---

# Phase 3

Interactive Terminal

Examples:

- Building Directory
- Product Search
- Employee Lookup
- Hospital Wayfinding
- Retail Catalogue
- Visitor Information

Requirements:

- On-screen keyboard
- Simplified keyboard layout
- No Ctrl/Alt/F-key shortcuts
- USB keyboard unlocks full administration
- Full-screen browser
- Cannot escape kiosk

---

# Architecture

Hardware

↓

Aurora DX

↓

DigiDisplay Bootstrap

↓

Firefox Kiosk

↓

Website

---

# Repository Structure

```
README.md
LICENSE
NOTICE
justfile

assets/
docker/
docs/
firefox/
scripts/
systemd/
wallpaper/
```

---

# Bootstrap

```
ujust digidisplay
```

Responsibilities:

- Verify Aurora DX
- Configure Firefox
- Configure Kiosk Mode
- Configure Autostart
- Configure Wallpaper
- Configure Branding

---

# Firefox

- Fullscreen
- Kiosk Mode
- Disable First Run
- Disable Password Manager
- Disable Telemetry
- Disable Update Prompts
- Disable Restore Session Prompts
- Restart automatically if closed

---

# Security

The kiosk stores no confidential information.

Content is public.

Users cannot:

- Exit Firefox
- Access KDE
- Open a terminal
- Access Settings

Administrator access is obtained through:

- USB keyboard
- SSH
- NoMachine
- Tailscale

---

# Future

## UpdateCase

- Remote Configuration
- Screenshots
- Heartbeats
- Scheduling
- Reporting

## Docker

- Offline Content
- Local Cache
- Synchronization

## Hardware

Primary target:

- x86 Mini PCs
- x86 Compute Sticks
- NUC-style devices

ARM support may be considered in the future when Aurora officially supports it.

---

# Development Philosophy

Every feature should answer one question:

> "Does this make it easier to transform an Aurora installation into a professional digital signage appliance?"

If the answer is **no**, it belongs in another project.