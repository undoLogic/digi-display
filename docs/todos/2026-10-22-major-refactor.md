# DigiDisplay Refactor Plan

Decisions from the October 22, 2026 planning session, written so they can be handed to Claude CLI as the source of truth for the refactor.

## Goals

- Streamline the pre-alpha open-core client so it can be sold.
- Split the product along the website's three segments: digital signage, interactive terminals and secure workstations.
- Keep the setup simple: a new user only needs `init` or `login`, then `apply`.
- Sales story: if a box breaks, buy a new box, plug it in, log in, and you're done.

## Core concepts

**Profile** decides how the machine behaves: `signage`, `terminal` or `workstation`.

**Mode** decides where the content comes from: `cloud` (a remote URL) or `local` (a Docker app on the box).

These are separate settings. Any profile can run in either mode.

**Override rule:** the profile fills in default values. Any key written explicitly in the JSON wins over the profile default. `status` should print the final settings and where each one came from (the profile or an override).

## Basic config

The basic config needs only three keys:

```json
{
  "profile": "signage",
  "mode": "cloud",
  "url": "https://www.digi-display.com/en/Pages/demoSlideshow"
}
```

- `url` is always present. In cloud mode it defaults to the demo slideshow. In local mode it defaults to localhost.
- `init` writes this basic file. `init --advanced` writes every available key.

## Profile defaults

### Digital signage

- Kiosk on
- Autologin on
- On-screen keyboard off
- Menu hidden
- Firefox restarts if it closes
- Waits for the network in cloud mode
- No idle return

### Interactive terminal

Everything from signage, plus:

- On-screen keyboard appears when a text field is touched
- Idle return: after 90 seconds with no input, go back to the home URL and clear whatever was typed (new key)
- No shortcut lockdown in the MVP, because Aurora's on-screen keyboard has no special keys. A physical USB keyboard is the admin escape hatch.

### Secure workstation (not launched yet; waiting for customers)

- Autologin off: the user logs into Linux, then the kiosk opens the app
- On-screen keyboard on touch, and a plugged-in keyboard also works
- Screen locks when idle (about 10 minutes) instead of returning home
- Users are local, non-sudo accounts created by hand. The README explains how.
- Docs warning: when switching an existing signage or terminal device to a workstation, reflash and redeploy from scratch. Settings like autologin are one-way, so `false` does not undo them.

## Commands

| Command | Purpose |
| --- | --- |
| `init` | Create a basic local config (`--advanced` writes all keys) |
| `login` | Enter email and password once; the server creates a token, which is stored in the JSON; then runs pull |
| `pull` | Re-fetch this group's config from the cloud |
| `apply` | Make the box match the config |
| `status` | Show the final settings, where each came from, and the logs |
| `update` | Explicitly update the local Docker app |

The other existing commands (launch, cancel, run, tailscale, activate-rdp, activate-ssh) become troubleshooting commands or are folded into `apply`.

## Cloud sync model

- The cloud is the single source of truth. Configs are edited in the Digi Display admin, and the box only pulls.
- There is no push or upload.
- Local edits are at your own risk (power-user territory). The next pull replaces them, and the timestamped backup is the only copy of the local version.

## Authentication (MVP)

- `login` runs on the box's command line, so no browser is needed.
- The server keeps a device tokens table linked to the customer's group. A token can only fetch its own group, and deleting a token cuts off that box.
- MVP shortcut, taken on purpose: the token and the read-only deploy key live inside `~/digidisplay.json`.
    - Update the spec, which currently says secrets never go in the JSON.
    - Set the permissions on the config and all timestamped backups to 600.
    - Add a README warning not to share the file.
- Use one read-only deploy key per customer repo.
- **Blocker:** fix the TLS certificate for site2.digi-display.com and remove `--insecure` before `login` goes live.

## Local mode

- The config holds the GitHub repo URL and branch.
- The source is cloned to `~/digidisplay-webroot`, next to the `~/digi-display` repo and not inside it, so each can be updated or wiped separately.
- Fixed SetupCase Core convention: go into the project's Docker Linux folder and run its start/build script. Projects must follow this convention.
- This replaces `docker_path` and most of the other `local.*` keys.
- The cloud stays the source of content. Nothing important should exist only in local Docker volumes.

## README structure

1. What DigiDisplay is: the three segments and the open-core idea
2. The three profiles, one short paragraph each
3. Quick start: clone, init or login, apply
4. Configuration: the basic example plus an Advanced section explaining overrides
5. Cloud vs local mode
6. Secure workstations: creating users, and the reflash warning
7. Commands, updating, recovery, license

Keep one spelling of the name: DigiDisplay in prose, lowercase only in commands and paths.

## Docs layout

- `docs/overview.md`: architecture, principles, open-core boundary
- `docs/profiles/signage.md`, `terminal.md`, `workstation.md`
- `docs/features/`: config-schema, login-pull-apply, local-runtime, kiosk-browser, remote-admin (how things work now)
- `docs/roadmap.md`: all future phases
- `docs/decisions/`: history, including the superseded aurora-ujust doc
- `CLAUDE.md` at the root: keep the feature docs accurate to the code, put new ideas in the roadmap, record changes in decisions

## Roadmap (deferred)

- Apply refuses to run the workstation profile while autologin is still active
- Make settings reversible (`false` actually turns features off)
- Workstation usernames listed in the cloud config and created by apply
- Branded maintenance wallpapers, `digidisplay-doctor`, VM QA checklist
- Automatic deploy-key registration through the GitHub API