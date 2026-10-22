# Roadmap

Everything planned but not built. Feature docs describe only what exists; ideas live here until they are implemented.

## Before cloud login goes live

- **Fix the TLS certificate for `site2.digi-display.com`.** `login` and `pull` verify TLS, so they fail until the certificate matches the hostname.
- **Server side:** device tokens table, `POST /loginDigiDisplay`, token-scoped `GET /configure` (see `features/login-pull-apply.md`).
- **Website side:** read `idle_return=<seconds>` and reset to the home page after that much idle time.

## Profiles

- `apply` refuses to run the workstation profile while autologin is still configured.
- Workstation usernames listed in the cloud config and created by `apply`.
- Workstation users currently each need their own `just apply`; a system-wide kiosk setup would remove that step.

## Config

- Make settings reversible: `false` actually turns SSH, RDP and autologin off.

## Local mode

- Automatic deploy-key registration through the GitHub API.
- Deterministic updates: check out an exact branch, tag or commit instead of fast-forwarding.

## Maintenance and diagnostics

- Branded maintenance wallpapers (updating, starting, error) shown while the kiosk is closed.
- `just doctor`: checks Aurora version, network, GPU, monitor modes (warn on low resolutions such as 1024x768), Firefox, Docker, and local app health. Never forces display modes.
- VM QA checklist: Aurora DX VM (2 vCPU, 4 GB RAM, 40 GB disk, UEFI, VirtIO) with a "Fresh Aurora" snapshot to restore between test runs.

## Managed fleet

- Device heartbeats, screenshots and update reporting to DigiDisplay cloud.

## Cleanup after this refactor

- Delete `old/` (legacy LXDE/NixOS scripts) once the refactor is verified.
