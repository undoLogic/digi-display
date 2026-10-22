# Login, Pull and Apply

**Status:** `init` and `apply` are implemented. `login` and `pull` are implemented on the device but need the server side (below) and a valid TLS certificate on `site2.digi-display.com` before they can work.

## The flow

```text
Cloud device:   just login  ->  (pull runs automatically)  ->  just apply
Local device:   just init   ->  edit ~/digidisplay.json    ->  just apply
Later changes:  edit in DigiDisplay admin  ->  just pull   ->  just apply
```

Messages show paths with `~` for the home folder. On Aurora the home folder is `/var/home/<user>`; with a user named `digidisplay`, that is `/var/home/digidisplay`.

The commands are separate on purpose: `pull` only downloads, and `apply` only reads the local file. There is no automatic polling, apply, or upload.

## `just init [profile] [--advanced]`

- Writes a new `~/digidisplay.json` with `profile` (default `signage`), `mode: cloud` and the demo `url`.
- `--advanced` writes every key, filled with that profile's resolved values.
- Refuses to overwrite an existing file.

## `just login`

1. Asks for email and password (the password is not shown).
2. Sends them, with the box's current hostname, to `POST /digiDisplayLogin` as JSON on stdin, so the password never appears on the command line. The password is never stored.
3. Stores the returned `token` in `~/digidisplay.json`, creating the file if needed. Every login creates a new token: one login = one box.
4. Runs `pull`.

## `just pull`

1. Reads `token` from the config. Without one it stops and says to run `just login`.
2. Sends `POST /digiDisplayConfigure` with `Authorization: Bearer <token>` and the box's current hostname as JSON. TLS is verified; there is no `--insecure`.
3. If the download fails or is not valid JSON, the active file is left unchanged.

When `login` or `pull` fails, it prints the server, the full URL, the HTTP status, any redirect target, the first 500 characters of the server's response, and a hint for common statuses (000, 30x, 400, 401, 403, 404, 405, 5xx). The password and token are never printed.
4. Moves the current file to `~/digidisplay-backups/digidisplay-YYYY_MM_DD_HH_MM_SS.json`, then saves the download as `~/digidisplay.json`.

Pull **overwrites all local edits**. The backup is the only copy of the local version. Backups are never deleted automatically; two pulls in the same second share a backup name.

The server writes the requesting box's own token into the config it returns, so the box can keep pulling. Boxes assigned to the same config get identical files except for the token.

Pull is the only time the box talks to the server; there are no other check-ins.

## `just apply`

Validates and resolves the config (see `config-schema.md`), then in order:

1. Sets the config and backups to mode 600 (the backup folder to 700).
2. Local mode: checks git, docker, curl and Docker Compose, and installs the deploy key.
3. Checks that Firefox is installed.
4. Sets `hostname` if given.
5. Enables SSH if `remote_admin.ssh` is true.
6. Installs the Firefox profile and the `digidisplay.service` user service.
7. Configures screen locking, power management, the on-screen keyboard, the menu and the wallpaper.
8. Configures autologin if `autologin` is true.
9. Installs the RDP fix if `remote_admin.rdp` is true.
10. Restarts `digidisplay.service`.
11. Reboots if `reboot_after_apply` is true.

An invalid config stops apply before step 1 changes anything. Apply never contacts the server.

## Server contract (UpdateCase/DigiDisplay server repo)

| Route | Request | Response |
| --- | --- | --- |
| `POST /digiDisplayLogin` | JSON `{"email", "password", "hostname"}` | `{"token": "..."}`; HTTP error on bad credentials |
| `POST /digiDisplayConfigure` | `Authorization: Bearer <token>`; JSON `{"hostname"}` | The assigned config's JSON with the request's `token` inserted, including `local.deploy_key` for local mode |

- **Configs** table: the customer's configs; one is the default for new logins. A customer without a config cannot log a box in.
- **Actives** table: one row per token (token, config_id, hostname, last_pulled_at). A token links to a config, not directly to the customer. Reassigning a box to another config takes effect on its next pull. Deleting the row cuts off only that box.
- Pull updates the row's hostname and `last_pulled_at`, so it is a POST (state-changing actions are never GET). The server validates the hostname (letters, digits, hyphens) before saving it.
- The server inserts the token taken from the request, never one stored on the config or group.
- Both routes start with `digiDisplay` because the same server also runs UpdateCase, so DigiDisplay does not take generic names such as `/login` or `/configure`. `/digiDisplayLogin` is separate from the existing website login.
- The full server spec is `docs/features/MVP-digiDisplay-login-cloud.md` in the server repo.
- `DIGIDISPLAY_SERVER` picks the server for `login` and `pull`: `production` (default, `https://site2.digi-display.com`), `staging` (`https://site2staging.digi-display.com`), or a full URL. `just status` shows the active one. Set it for every `login` and `pull`, because a token from one server is rejected by the other:

  ```bash
  export DIGIDISPLAY_SERVER=staging    # this terminal only
  echo 'export DIGIDISPLAY_SERVER=staging' >> ~/.bashrc    # every terminal on this box
  ```

## Testing

### Init and apply

**Intent:** A device can be set up from a local file with no cloud account.

**Surfaces:**
- `scripts/digidisplay-init`, `scripts/digidisplay-apply`

#### Scenarios

- [ ] `just init` creates a 3-key file with mode 600.
- [ ] `just init` when the file exists stops without changing it and prints the edit and start-over commands.
- [ ] `just init bogus` stops with the usage message.
- [ ] `just apply` on a valid file finishes with "Configuration applied" and the kiosk opens.
- [ ] `just apply` on invalid JSON stops before changing any setting.

### Login and pull

**Intent:** A device gets its config from the cloud and keeps a backup of what it replaced.

**Surfaces:**
- `scripts/digidisplay-login`, `scripts/digidisplay-pull`
- Server: `POST /digiDisplayLogin`, `POST /digiDisplayConfigure`

#### Scenarios

- [ ] `just login` with correct credentials saves the token, pulls, and prints "Run: just apply".
- [ ] `just login` with wrong credentials prints "Login failed" and leaves the file unchanged.
- [ ] `just pull` without a token says to run `just login`.
- [ ] A `just pull` creates a timestamped backup in `~/digidisplay-backups/` with mode 600, and nothing new appears in `~`.
- [ ] A failed download leaves the active file unchanged.
- [ ] After a pull, the new file still contains this box's token.
- [ ] Two boxes on the same config get identical files apart from `token`.
- [ ] After a pull, DigiDisplay Actives shows the box's current hostname and pull time.
- [ ] Logging in a second box creates a second token; revoking one leaves the other working.
- [ ] The password and token do not appear in `ps` output during login or pull.
- [ ] With `DIGIDISPLAY_SERVER=staging`, `just status` shows the staging server and `login`/`pull` talk to it.
