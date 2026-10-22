# DigiDisplay Refactor Plan

## Description

Decisions from the October 22, 2026 planning session, written so they can be handed to Claude CLI as the source of truth for the refactor.

This is a breaking refactor. Existing devices and old code do not need to be preserved; each step is verified manually before the next one starts. The author's decisions are kept unchanged under Notes. The Open questions and Implementation plan sections below them are Claude's proposal for review before programming starts.

## Notes

### Goals

- Streamline the pre-alpha open-core client so it can be sold.
- Split the product along the website's three segments: digital signage, interactive terminals and secure workstations.
- Keep the setup simple: a new user only needs `init` or `login`, then `apply`.
- Sales story: if a box breaks, buy a new box, plug it in, log in, and you're done.

### Core concepts

**Profile** decides how the machine behaves: `signage`, `terminal` or `workstation`.

**Mode** decides where the content comes from: `cloud` (a remote URL) or `local` (a Docker app on the box).

These are separate settings. Any profile can run in either mode.

**Override rule:** the profile fills in default values. Any key written explicitly in the JSON wins over the profile default. `status` should print the final settings and where each one came from (the profile or an override).

### Basic config

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

### Profile defaults

#### Digital signage

- Kiosk on
- Autologin on
- On-screen keyboard off
- Menu hidden
- Firefox restarts if it closes
- Waits for the network in cloud mode
- No idle return

#### Interactive terminal

Everything from signage, plus:

- On-screen keyboard appears when a text field is touched
- Idle return: after 90 seconds with no input, go back to the home URL and clear whatever was typed (new key)
- No shortcut lockdown in the MVP, because Aurora's on-screen keyboard has no special keys. A physical USB keyboard is the admin escape hatch.

#### Secure workstation (not launched yet; waiting for customers)

- Autologin off: the user logs into Linux, then the kiosk opens the app
- On-screen keyboard on touch, and a plugged-in keyboard also works
- Screen locks when idle (about 10 minutes) instead of returning home
- Users are local, non-sudo accounts created by hand. The README explains how.
- Docs warning: when switching an existing signage or terminal device to a workstation, reflash and redeploy from scratch. Settings like autologin are one-way, so `false` does not undo them.

### Commands

| Command | Purpose |
| --- | --- |
| `init` | Create a basic local config (`--advanced` writes all keys) |
| `login` | Enter email and password once; the server creates a token, which is stored in the JSON; then runs pull |
| `pull` | Re-fetch this group's config from the cloud |
| `apply` | Make the box match the config |
| `status` | Show the final settings, where each came from, and the logs |
| `update` | Explicitly update the local Docker app |

The other existing commands (launch, cancel, run, tailscale, activate-rdp, activate-ssh) become troubleshooting commands or are folded into `apply`.

### Cloud sync model

- The cloud is the single source of truth. Configs are edited in the Digi Display admin, and the box only pulls.
- There is no push or upload.
- Local edits are at your own risk (power-user territory). The next pull replaces them, and the timestamped backup is the only copy of the local version.

### Authentication (MVP)

- `login` runs on the box's command line, so no browser is needed.
- The server keeps a device tokens table linked to the customer's group. A token can only fetch its own group, and deleting a token cuts off that box.
- MVP shortcut, taken on purpose: the token and the read-only deploy key live inside `~/digidisplay.json`.
    - Update the spec, which currently says secrets never go in the JSON.
    - Set the permissions on the config and all timestamped backups to 600.
    - Add a README warning not to share the file.
- Use one read-only deploy key per customer repo.
- **Blocker:** fix the TLS certificate for site2.digi-display.com and remove `--insecure` before `login` goes live.

### Local mode

- The config holds the GitHub repo URL and branch.
- The source is cloned to `~/digidisplay-webroot`, next to the `~/digi-display` repo and not inside it, so each can be updated or wiped separately.
- Fixed SetupCase Core convention: go into the project's Docker Linux folder and run its start/build script. Projects must follow this convention.
- This replaces `docker_path` and most of the other `local.*` keys.
- The cloud stays the source of content. Nothing important should exist only in local Docker volumes.

### README structure

1. What DigiDisplay is: the three segments and the open-core idea
2. The three profiles, one short paragraph each
3. Quick start: clone, init or login, apply
4. Configuration: the basic example plus an Advanced section explaining overrides
5. Cloud vs local mode
6. Secure workstations: creating users, and the reflash warning
7. Commands, updating, recovery, license

Keep one spelling of the name: DigiDisplay in prose, lowercase only in commands and paths.

### Docs layout

- `docs/overview.md`: architecture, principles, open-core boundary
- `docs/profiles/signage.md`, `terminal.md`, `workstation.md`
- `docs/features/`: config-schema, login-pull-apply, local-runtime, kiosk-browser, remote-admin (how things work now)
- `docs/roadmap.md`: all future phases
- `docs/decisions/`: history, including the superseded aurora-ujust doc
- `CLAUDE.md` at the root: keep the feature docs accurate to the code, put new ideas in the roadmap, record changes in decisions

### Roadmap (deferred)

- Apply refuses to run the workstation profile while autologin is still active
- Make settings reversible (`false` actually turns features off)
- Workstation usernames listed in the cloud config and created by apply
- Branded maintenance wallpapers, `digidisplay-doctor`, VM QA checklist
- Automatic deploy-key registration through the GitHub API

## Decisions

Answers from the review of Claude's open questions, with the author's answer quoted and how the plan applies it.

1. **Command names.** Short names inside the repo folder: `just init`, `just login`, `just pull`, `just apply`, `just status`, `just launch`, `just cancel`, `just tailscale`. `update` becomes `just update-app`, because `ujust update` updates Aurora itself. `just` only reads the repo's `justfile`, so there is no clash with `ujust`; the README quick start always starts with `cd ~/digi-display`.
2. **`version` key.** Answer: "GOOD". Dropped.
3. **Pull overwrites everything.** Answer: "IF THEY PULL IT IS UNDERSTOOD THEY WILL OVERWRITE ALL LOCAL CHANGES". `pull` writes the server response as-is and does not copy anything across. Confirmed: the server stores the token with the group's config, so every pulled config already contains `token` (and the deploy key). The first `login` writes the token locally; later pulls bring the same token back down. The token is already visible in the file, so returning it costs little and keeps pull a plain overwrite.
4. **Login route.** Answer: "USE A DIFFERENT ROUTE /loginDigiDisplay SO IT WILL NOT CONFLICT WITH EXISTING LOGIN SYSTEM". `POST /loginDigiDisplay` with `{email, password}` returns `{token}`. `GET /configure` with `Authorization: Bearer <token>` returns the group's config. The unauthenticated `/configure/{group_id}` route is removed. Later renamed on the server: `POST /digiDisplayLogin` and `POST /digiDisplayConfigure` (see `docs/decisions/2026-10-22-login-tokens-configs.md`).
5. **Local Docker convention.** Answer: "/dockerLinux/1startDocker.sh". `apply` and `update-app` run `~/digidisplay-webroot/dockerLinux/1startDocker.sh` from inside `dockerLinux/`. Readiness is checked by polling `url`.
6. **Workstation profile.** Answer: "NOW - AUTOLOGIN OFF, IDLE LOCK". Implemented now.
7. **Idle return.** Answer: "MAKE A GET PARAM IN THE ADDRESS BAR THAT WILL BE PASSED INTO THE SITE ?idle_return=1 and this will be build into our website that is the screen". DigiDisplay only adds the parameter to the URL Firefox opens; the website does the reset. Confirmed: the box passes the seconds. The key `idle_return` is an integer number of seconds; `0` (the default) means disabled. When it is above 0, `launch` appends `idle_return=<seconds>` (e.g. `idle_return=90`) with `?` or `&` as needed. When it is 0 the parameter is left off.
8. **Tests.** Answer: "THIS IS MVP NO TESTS - I WILL BE MANUALLY TESTING EVERYTHING MYSELF". Delete `tests/` and the `test` recipe. Feature docs keep `## Testing` sections as manual checks.
9. **Troubleshooting commands.** Answer: "SOUNDS GOOD". Keep `launch` and `cancel`, delete `run`, fold `activate-ssh` and `activate-rdp` into `apply`, keep `tailscale` as opt-in.
10. **Leftover keys.** Answer: "GOOD". Keep `hostname` and `reboot_after_apply`; drop `update.automatic`, `remote_admin.tailscale`, `remote_admin.nomachine`, `group_id`.
11. **`init` profile.** Answer: "GOOD". `just init [profile] [--advanced]`, default `signage`.
12. **Agent files.** Answer: "I REMOVED THE BAD ONE AND ONLY THE GOOD ONE REMAINS ALL CAPS". `AGENTS.md` stays as-is. No `CLAUDE.md` (see decision 14).
13. **`old/` folder.** Answer: "KEEP UNTIL THIS ROUND OF UPDATES IS COMPELTED". Deleted in the final phase, not phase 0.
14. **No `CLAUDE.md`.** Replaces the `CLAUDE.md` line in Notes > Docs layout. Everything planned for `CLAUDE.md` goes into `docs/README.md` instead, so `AGENTS.md` can reference `docs/README.md` as a company-wide standard across projects. `docs/README.md` holds the docs index (what each file covers) and the maintenance rules: keep the feature docs accurate to the code, put new ideas in the roadmap, record changes in decisions. The author updates `AGENTS.md` to point at it.

## Implementation plan

Each phase ends with a manual check on a device or VM before the next phase starts. Phases 1-4 do not need the server; phase 5 is blocked by the TLS certificate.

### Phase 0: Clean the repo

- Delete `config/digidisplay.json.example`, `scripts/digidisplay-run`, `scripts/digidisplay-activate-ssh`, `scripts/digidisplay-activate-rdp` (logic moves into apply), `tests/` and the `test` recipe. `old/` stays until phase 7.
- Move `docs/features/aurora-ujust.md`, `digi-display-config-pull-apply-codex.md` and `local_docker_offline.md` to `docs/decisions/` as history. Their still-current content is rewritten in phase 6.

### Phase 1: One config resolver

- New `scripts/lib/digidisplay-config` (Python). It merges built-in defaults, then the profile defaults, then the keys written in the JSON, validates the result, and outputs either shell variables (for the scripts) or a table with a source column (for `status`).
- Profile defaults are data files: `config/profiles/signage.json`, `terminal.json`, `workstation.json`.
- This replaces the four copies of `json_value` and the inline validation in `apply`, `launch`, `status` and `update`.
- Proposed key set (`init --advanced` writes all of these):

| Key | signage | terminal | workstation | Notes |
| --- | --- | --- | --- | --- |
| `profile` | | | | required |
| `mode` | | | | required, `cloud` or `local` |
| `url` | | | | cloud: demo slideshow; local: `http://localhost` |
| `hostname` | | | | omitted: hostname unchanged |
| `kiosk` | true | true | true | |
| `autologin` | true | true | false | one-way |
| `restart_browser` | true | true | true | |
| `wait_for_network` | cloud only | cloud only | cloud only | true in cloud, false in local |
| `hide_menu` | true | true | true | |
| `virtual_keyboard` | `off` | `on_touch` | `on_touch` | `off`, `on_touch`, `always`; replaces `virtual_keyboard.always_show` |
| `idle_return` | 0 | 90 | 0 | new; seconds, 0 = disabled; adds `idle_return=<seconds>` to the URL, the website does the reset |
| `idle_lock_minutes` | 0 | 0 | 10 | new; 0 = off |
| `remote_admin.ssh` | false | false | false | one-way |
| `remote_admin.rdp` | false | false | false | one-way |
| `reboot_after_apply` | false | false | false | |
| `token` | | | | written by `login` |
| `local.repository` | | | | required in local mode |
| `local.branch` | | | | default `main` |
| `local.deploy_key` | | | | private key text from the server; written to `~/.ssh/` with mode 600 at apply |

- Removed keys: `version`, `virtual_keyboard.always_show`, `group_id`, `update.automatic`, `remote_admin.tailscale`, `remote_admin.nomachine`, `local.project_path`, `local.docker_path`, `local.ssh_key`, `local.health_url`.
- Check: the resolver prints the expected table for each profile and mode, and a key written in the JSON shows as "override".

### Phase 2: `init`, `apply`, `status`

- `init [profile] [--advanced]` writes the basic file, or the fully resolved one. It is generated from the resolver, so there is no template to keep in sync.
- `apply` reads only resolved values. It includes the SSH and RDP steps, sets mode 600 on the config and all backups, and keeps the existing KDE, Firefox, service, wallpaper and autologin steps.
- `status` prints the resolved table with sources, then the service state and logs.
- Check: `init` then `apply` on a fresh VM gives the same signage kiosk as today.

### Phase 3: Profile behaviour

- Virtual keyboard: `on_touch` maps to Plasma's automatic mode, and `off` leaves no input method set.
- Idle lock for workstation: KDE screen locker with `idle_lock_minutes`, instead of the current "never lock".
- Idle return for terminal: `launch` appends `idle_return=<seconds>` to `url` when the value is above 0 (decision 7). The website side is built separately.
- Check: each profile behaves as described in Notes on a touch-capable VM or device.

### Phase 4: Local mode rewrite

- Clone to `~/digidisplay-webroot`, run `dockerLinux/1startDocker.sh` from inside `dockerLinux/` (decision 5), poll `url`, then open Firefox.
- `update` is renamed `update-app` and keeps its rules: clean fast-forward only, no volume deletion, kiosk closed on failure.
- Delete the code for the old `local.*` keys from `scripts/lib/digidisplay-local-runtime`.
- Check: a SetupCase Core project starts from a fresh clone, and `update` fast-forwards it.

### Phase 5: `login` and `pull` (blocked by the TLS certificate)

- `login` asks for the email and a hidden password, calls the server, stores `token`, then runs `pull`.
- `pull` takes no argument, sends the token, keeps the timestamped backup, writes the server response as-is (decision 3), and drops `--insecure`.
- Server repo: Configs and Actives tables, `POST /digiDisplayLogin`, and token-scoped `POST /digiDisplayConfigure`, which inserts the requesting box's token into the returned config (see `docs/decisions/2026-10-22-login-tokens-configs.md`).
- Check: login on a fresh box, change the config in the admin, pull, apply.

### Phase 6: Docs

- Rewrite `README.md` to the structure in Notes.
- Write `docs/overview.md`, `docs/profiles/*.md`, the five `docs/features/*.md` files (each with a `## Testing` section of manual checks), `docs/roadmap.md`, and `docs/README.md` (decision 14).
- Fold `docs/install/aurora-dx.md` and `docs/recovery/kiosk.md` into the README and the feature docs, then delete them.
- Check: read on phone; every command and key in the docs exists in the code, and nothing in the code is undocumented.

### Phase 7: Final cleanup

- Delete `old/` (decision 13).
- Search the repo for removed command and key names, and remove any leftovers.
- Check: `git grep` finds no `digidisplay-pull`, `group_id`, `docker_path`, `always_show` or other removed names outside `docs/decisions/`.
