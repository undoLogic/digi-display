# DigiDisplay configuration pull/apply MVP

## Purpose

This is the MVP specification for replacing the current question-driven DigiDisplay setup with a simple JSON workflow:

```text
pull JSON -> optionally edit JSON -> apply JSON
```

The DigiDisplay device remains a URL runtime:

- `cloud` mode opens a remote URL in Firefox.
- `local` mode starts the existing Git/Docker Compose runtime and opens its localhost URL in Firefox.

The goal is to reuse the programming already in this Aurora client, keep the first implementation small, and start testing it manually.

## Existing implementation to preserve

- Commands in this repository are `just` recipes, not installed `ujust` recipes.
- The active configuration is `~/digidisplay.json`.
- Configuration-reading scripts support the `DIGIDISPLAY_CONFIG` override.
- The current schema is version `1`.
- Existing modes are `cloud` and `local`. Do not add a separate `docker` mode.
- `local` mode already clones a missing Git repository, starts Docker Compose, waits for a health URL, and opens the configured display URL.
- Updating an existing local Git checkout remains the job of `just digidisplay-update`.
- The systemd user service remains `digidisplay.service`.
- Tailscale remains separate from configuration pull/apply.

The CakePHP configuration endpoint belongs to the separate UpdateCase/Digi-Display server repository. This repository contains only the Aurora client.

## MVP commands

Add:

```bash
just digidisplay-pull
just digidisplay-pull 123
just digidisplay-apply
```

Normal use:

```bash
cd ~/digi-display
just digidisplay-pull 123
nano ~/digidisplay.json
just digidisplay-apply
```

The commands remain separate:

- `pull` only downloads and stores JSON.
- `apply` only reads the local JSON and configures the device.

There is no automatic polling, automatic cloud check-in, automatic apply, or upload of local edits.

## Configuration file

The active file remains:

```text
~/digidisplay.json
```

This is in Aurora's mutable home directory, so the configuration and its backups survive normal reboots and image updates.

### Cloud example

```json
{
  "version": 1,
  "group_id": false,
  "hostname": "digidisplay",
  "mode": "cloud",
  "url": "https://www.undologic.com/en/pages/screen",
  "kiosk": true,
  "wait_for_network": true,
  "restart_browser": true,
  "autologin": true,
  "reboot_after_apply": false,
  "hide_menu": true,
  "virtual_keyboard": {
    "always_show": false
  },
  "remote_admin": {
    "tailscale": false,
    "ssh": false,
    "rdp": false,
    "nomachine": false
  },
  "update": {
    "automatic": false
  }
}
```

### Local/Docker example

```json
{
  "version": 1,
  "group_id": false,
  "hostname": "digidisplay-local",
  "mode": "local",
  "url": "http://localhost",
  "kiosk": true,
  "wait_for_network": false,
  "restart_browser": true,
  "autologin": true,
  "reboot_after_apply": false,
  "hide_menu": true,
  "virtual_keyboard": {
    "always_show": false
  },
  "remote_admin": {
    "tailscale": false,
    "ssh": false,
    "rdp": false,
    "nomachine": false
  },
  "local": {
    "repository": "git@github.com:example/private-project.git",
    "branch": "main",
    "project_path": "~/DigiDisplay/projects/client-project",
    "docker_path": "docker-wsl",
    "ssh_key": "~/.ssh/digidisplay",
    "health_url": "http://localhost/"
  },
  "update": {
    "automatic": false
  }
}
```

Top-level `url` is always the URL opened by Firefox. In local mode, `local.health_url` is only the Docker application's readiness check.

`local.ssh_key` is a path to a key already installed on the device. Never put private-key contents, passwords, or tokens in this JSON.

## All previous setup questions move to JSON

`digidisplay-apply` must not ask configuration questions. Every value previously collected by the interactive setup comes from the local JSON:

| Previous setup question | JSON field |
| --- | --- |
| Hostname | `hostname` |
| Deployment mode | `mode` |
| Git repository | `local.repository` |
| Git branch | `local.branch` |
| Local project path | `local.project_path` |
| Docker Compose directory | `local.docker_path` |
| SSH private-key path for Git | `local.ssh_key` |
| Local health URL | `local.health_url` |
| Display URL | `url` |
| Firefox kiosk mode | `kiosk` |
| Restart Firefox automatically | `restart_browser` |
| Always show on-screen keyboard | `virtual_keyboard.always_show` |
| Enable SSH server | `remote_admin.ssh` |
| Enable desktop autologin | `autologin` |
| Hide the Aurora bottom menu until the pointer reaches the bottom edge | `hide_menu` |
| Activate the RDP/KRDP SELinux fix | `remote_admin.rdp` |
| Reboot after apply | `reboot_after_apply` |

For an existing version-1 file that does not contain the new fields, use these in-memory defaults without rewriting the file:

```json
{
  "group_id": false,
  "autologin": false,
  "reboot_after_apply": false,
  "hide_menu": true,
  "remote_admin": {
    "rdp": false
  }
}
```

The interactive setup is removed completely for the MVP. There is no compatibility wizard, prompt wrapper, or second configuration path. Administrators either pull a configuration, run `just digidisplay-init` for a current local template, or edit `~/digidisplay.json`, then run `just digidisplay-apply`.

For a new local-only device, the manual starting point is:

```bash
just digidisplay-init
nano ~/digidisplay.json
cd ~/digi-display
just digidisplay-apply
```

## Simple timestamped backups

Before a DigiDisplay command replaces an existing configuration, rename the old file in the same directory using the device's local time:

```text
~/digidisplay-YYYY_MM_DD_HH_MM_SS.json
```

Example:

```text
~/digidisplay-2026_08_16_10_02_11.json
```

If `DIGIDISPLAY_CONFIG` is `/path/device.json`, its backup is named like:

```text
/path/device-2026_08_16_10_02_11.json
```

MVP rules:

- The first write has no backup because no old file exists.
- Backups are not automatically deleted.
- Two writes in the same second may overwrite the backup with that timestamp.
- Manual editing with `nano` or another editor does not create a backup.
- No backup-retention policy, locking, checksum, or automatic recovery system is required for the MVP.

## `digidisplay-pull`

### Endpoint

Use:

```text
https://site2.digi-display.com/configure
https://site2.digi-display.com/configure/123
```

Requests:

```http
GET /configure
GET /configure/{group_id}
Accept: application/json
```

The optional `group_id` is a positive integer. It is an MVP lookup value, not a secret or a final authentication system.

The no-argument endpoint returns a complete default version-1 configuration with:

```json
"group_id": false
```

The group endpoint returns a complete version-1 configuration with its integer `group_id`.

### Simple pull flow

The MVP pull implementation should be straightforward:

1. Build the no-group or group URL.
2. Download it with `curl --insecure --fail` to a temporary sibling file such as `~/digidisplay.json.download`. Insecure TLS is an explicit temporary MVP choice while the server certificate does not match `site2.digi-display.com`.
3. If the download fails, leave the active configuration alone and report the error.
4. If `~/digidisplay.json` exists, rename it to its timestamped backup.
5. Rename the downloaded file to `~/digidisplay.json`.
6. Print the active path, backup path when one was created, and `Run: just digidisplay-apply`.

Do not add schema normalization, response-ID matching, checksums, signatures, file locking, automatic rollback, backup pruning, or other download machinery for the MVP. `digidisplay-apply` is responsible for rejecting JSON it cannot use. If the final move fails after the backup was created, report the error and leave the backup available for manual recovery.

`pull` must not apply settings, restart services, launch Firefox, start Docker, update Git, activate RDP, enroll Tailscale, or reboot.

## `digidisplay-apply`

### Basic validation

Keep validation limited to what is required to avoid applying an unusable configuration:

- The file exists and contains a JSON object.
- `version` is `1`.
- `mode` is `cloud` or `local`.
- `url` starts with `http://` or `https://`.
- The fields used as booleans contain JSON booleans when present.
- `hostname` passes the existing hostname check.
- Local mode has `local.repository`, `local.branch`, `local.project_path`, `local.docker_path`, and an HTTP(S) `local.health_url`.

On invalid JSON or missing required values, print a useful error and stop before changing machine settings. The administrator can fix the file or restore the most recent timestamped backup.

Do not rewrite or normalize the JSON during apply. Missing newly added fields use the in-memory defaults documented above.

### Apply flow

`scripts/digidisplay-apply` becomes the one configuration/setup implementation. Move the useful noninteractive operations from `scripts/digidisplay-bootstrap` into this script, then remove the old bootstrap script and its prompt helpers. Do not keep a second shared bootstrap workflow or preserve the step-by-step questions.

After basic validation, `digidisplay-apply` performs:

1. Configure `hostname`.
2. Enable SSH when `remote_admin.ssh` is `true`.
3. Install/update the Firefox profile.
4. Install/update and enable `digidisplay.service`, using `restart_browser` for its restart policy.
5. Configure KDE locking and power management.
6. Configure the virtual keyboard.
7. Install/apply the wallpaper.
8. Configure desktop autologin when `autologin` is `true`.
9. Apply the existing RDP/KRDP fix when `remote_admin.rdp` is `true`.
10. Start or restart `digidisplay.service` so the configuration becomes active.
11. Reboot only when `reboot_after_apply` is `true` and the earlier steps succeeded.

For the MVP, SSH, RDP, and autologin keep their current one-way behavior. A `false` value means do not enable or configure that feature; it does not undo a previous activation.

In local mode, starting the service keeps the current behavior:

- Clone the configured repository only when it is missing.
- Run Docker Compose.
- Wait for `local.health_url`.
- Open top-level `url` in Firefox.
- Do not update an existing checkout; `just digidisplay-update` remains explicit.

`apply` does not contact the configuration server, change `group_id`, enroll Tailscale, upload local edits, or enable automatic updates.

## Local-only and cloud-managed use

Community/self-managed devices use:

```json
"group_id": false
```

They can create or edit `~/digidisplay.json` and run `just digidisplay-apply` without a Digi-Display account or any server contact.

Cloud-managed use is intentionally manual:

```text
edit configuration in Digi-Display SaaS
-> just digidisplay-pull <group_id>
-> review ~/digidisplay.json
-> just digidisplay-apply
```

Local edits are not uploaded and the next successful pull replaces them after making a timestamped backup.

## MVP security boundary

- `group_id` is not authentication and must not be treated as a secret.
- Use HTTPS, but temporarily disable certificate verification for the MVP because the current certificate does not match `site2.digi-display.com`.
- Restore normal certificate verification as soon as the server certificate is corrected.
- Do not return passwords, tokens, private keys, or other secrets.
- Keep Tailscale enrollment separate.
- Proper device authentication can be added after the MVP is working.

## MVP implementation scope

### Aurora client repository

1. Add `scripts/digidisplay-pull` and its optional group argument in the `justfile`.
2. Create `scripts/digidisplay-apply` and its `justfile` recipe as the only configuration/setup path.
3. Move the useful machine-configuration functions from `scripts/digidisplay-bootstrap` into `scripts/digidisplay-apply`.
4. Remove all question/prompt, interactive config-writing, and interactive reboot code.
5. Remove `scripts/digidisplay-bootstrap` and the old `just digidisplay` recipe after its required apply logic has moved.
6. Add the new JSON fields to `config/digidisplay.json.example`.
7. Add the simple timestamped backup behavior when pull replaces an existing config.
8. Update README command/configuration documentation and remove interactive setup instructions.
9. Preserve the other existing runtime commands and local-mode behavior.

### UpdateCase/Digi-Display server repository

1. Add `/configure` and `/configure/{group_id}` JSON routes.
2. Return complete version-1 JSON using the schema in this document.
3. Return `group_id: false` for the no-group default.
4. Keep secrets out of the response.

## Manual MVP check

Do not add or expand automated tests for this MVP. Testing is manual.

The MVP is ready for initial device testing when this works on Aurora DX:

```bash
cd ~/digi-display
just digidisplay-pull 123
ls -l ~/digidisplay*.json
nano ~/digidisplay.json
just digidisplay-apply
```

Confirm manually that:

- A second pull creates a timestamped backup.
- The downloaded configuration is visible before apply.
- Cloud mode opens the configured remote URL.
- Local mode retains the current Docker behavior.
- Autologin, SSH, RDP, virtual keyboard, restart policy, hostname, and optional reboot follow the JSON.
- A device with `group_id: false` still works without a Digi-Display cloud account.
