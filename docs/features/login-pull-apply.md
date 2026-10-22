# Login, Pull and Apply

**Status:** `init` and `apply` are implemented. `login` and `pull` are implemented on the device but need the server side (below) and a valid TLS certificate on `site2.digi-display.com` before they can work.

## The flow

```text
Cloud device:   just login  ->  (pull runs automatically)  ->  just apply
Local device:   just init   ->  edit ~/digidisplay.json    ->  just apply
Later changes:  edit in DigiDisplay admin  ->  just pull   ->  just apply
```

The commands are separate on purpose: `pull` only downloads, and `apply` only reads the local file. There is no automatic polling, apply, or upload.

## `just init [profile] [--advanced]`

- Writes a new `~/digidisplay.json` with `profile` (default `signage`), `mode: cloud` and the demo `url`.
- `--advanced` writes every key, filled with that profile's resolved values.
- Refuses to overwrite an existing file.

## `just login`

1. Asks for email and password (the password is not shown).
2. Sends them to `POST /loginDigiDisplay` as JSON on stdin, so the password never appears on the command line.
3. Stores the returned `token` in `~/digidisplay.json`, creating the file if needed.
4. Runs `pull`.

## `just pull`

1. Reads `token` from the config. Without one it stops and says to run `just login`.
2. Downloads `GET /configure` with `Authorization: Bearer <token>`. TLS is verified; there is no `--insecure`.
3. If the download fails or is not valid JSON, the active file is left unchanged.
4. Renames the current file to `~/digidisplay-YYYY_MM_DD_HH_MM_SS.json`, then saves the download as `~/digidisplay.json`.

Pull **overwrites all local edits**. The backup is the only copy of the local version. Backups are never deleted automatically; two pulls in the same second share a backup name.

The token is stored with the group's config on the server, so every pulled config already contains it, and the box can keep pulling.

## `just apply`

Validates and resolves the config (see `config-schema.md`), then in order:

1. Sets the config and backups to mode 600.
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
| `POST /loginDigiDisplay` | JSON `{"email", "password"}` | `{"token": "..."}`; HTTP error on bad credentials |
| `GET /configure` | `Authorization: Bearer <token>` | The group's complete config JSON, including `token` and, for local mode, `local.deploy_key` |

- A device tokens table links each token to one customer group. A token can only fetch its own group; deleting the token cuts off that box.
- `/loginDigiDisplay` is separate from the existing website login.
- The server can be changed for testing with `DIGIDISPLAY_SERVER` (default `https://site2.digi-display.com`).

## Testing

### Init and apply

**Intent:** A device can be set up from a local file with no cloud account.

**Surfaces:**
- `scripts/digidisplay-init`, `scripts/digidisplay-apply`

#### Scenarios

- [ ] `just init` creates a 3-key file with mode 600.
- [ ] `just init` when the file exists stops without changing it.
- [ ] `just init bogus` stops with the usage message.
- [ ] `just apply` on a valid file finishes with "Configuration applied" and the kiosk opens.
- [ ] `just apply` on invalid JSON stops before changing any setting.

### Login and pull

**Intent:** A device gets its config from the cloud and keeps a backup of what it replaced.

**Surfaces:**
- `scripts/digidisplay-login`, `scripts/digidisplay-pull`
- Server: `POST /loginDigiDisplay`, `GET /configure`

#### Scenarios

- [ ] `just login` with correct credentials saves the token, pulls, and prints "Run: just apply".
- [ ] `just login` with wrong credentials prints "Login failed" and leaves the file unchanged.
- [ ] `just pull` without a token says to run `just login`.
- [ ] A second `just pull` creates a timestamped backup with mode 600.
- [ ] A failed download leaves the active file unchanged.
- [ ] After a pull, the new file still contains the token.
- [ ] The password and token do not appear in `ps` output during login or pull.
