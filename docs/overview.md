# Overview

DigiDisplay turns an Aurora DX computer into a dedicated browser appliance: a screen that opens one website in Firefox kiosk mode and keeps it running.

## Products

The website sells three segments, and each maps to a **profile**:

| Segment | Profile | In one line |
| --- | --- | --- |
| Digital signage | `signage` | Shows content all day; nobody touches it |
| Interactive terminals | `terminal` | People touch it; it resets when they leave |
| Secure workstations | `workstation` | Each person logs in; it locks when left alone |

A separate setting, **mode**, decides where the content comes from: `cloud` (a remote URL) or `local` (a Docker app on the box). Any profile can run in either mode.

## Architecture

```text
Hardware (x86 mini PC, NUC, repurposed PC)
  -> Aurora DX (immutable OS)
  -> DigiDisplay (this repo: just recipes + Bash scripts)
  -> ~/digidisplay.json (profile + mode + overrides)
  -> systemd user service digidisplay.service
  -> Firefox kiosk
  -> cloud URL, or local Docker app at http://localhost
```

The box never decides anything on its own. An administrator runs `just apply`, `just pull` or `just update-app`; otherwise the box keeps running exactly as it is.

## Open-core boundary

| Free (this repo, Apache 2.0) | Paid (DigiDisplay cloud) |
| --- | --- |
| Turning Aurora DX into a kiosk | Managed configs per customer group |
| Profiles, local configs, local mode | `just login` and `just pull` |
| Recovery and troubleshooting commands | Hosting, content (UpdateCase), support, hardware |

A device with a local config works without any DigiDisplay account.

## Principles

- **Explicit over automatic.** Nothing changes on a deployed box unless someone runs a command. No automatic pulls, updates or OS upgrades.
- **The cloud is the source of truth.** Configs are edited in the DigiDisplay admin; the box only pulls. Local edits are allowed but overwritten by the next pull.
- **Content and code are separate.** The website updates its own content. `update-app` updates code, only on request.
- **Containers are disposable; data is not.** Nothing deletes Docker volumes, and nothing important should live only in them.
- **Simple tools.** Bash and `just`, one Python helper to read the config. No extra daemons.
- **Aurora DX on x86 is the supported host.**
