# 2026-10-22: Profiles, Short Commands and Cloud Login

## What changed

- **Profiles.** A new `profile` key (`signage`, `terminal`, `workstation`) sets the defaults, matching the website's three product segments. `mode` (`cloud`/`local`) stays a separate setting. Any key written in the config overrides the profile; `just status` shows where each value came from.
- **Basic config.** Only `profile`, `mode` and `url` are needed. `init --advanced` writes every key.
- **One config reader.** `scripts/lib/digidisplay-config` replaced the four copies of `json_value` and the inline validation. Unknown keys are now rejected.
- **Short commands.** `just init`, `login`, `pull`, `apply`, `status`, `launch`, `cancel`, `tailscale`. `update` became `update-app` so it is not confused with `ujust update`, which upgrades Aurora. `run`, `activate-ssh` and `activate-rdp` were removed; SSH and RDP live in `apply`.
- **Cloud login.** `pull <group_id>` was replaced by `login` (email and password, returns a device token) and a token-authenticated `pull`. `--insecure` was removed. The server routes are `POST /digiDisplayLogin` and `POST /digiDisplayConfigure`, prefixed because the same server also runs UpdateCase.
- **Secrets in the config.** As an intentional MVP shortcut, the device token and the local deploy key live in `~/digidisplay.json`, protected with mode 600. This reverses the earlier "no secrets in the JSON" rule.
- **Local mode.** Fixed paths replace the old `local.*` keys: the app is cloned to `~/digidisplay-webroot` and started with `dockerLinux/1startDocker.sh`; `url` is the readiness check.
- **Backups folder.** `pull` keeps timestamped backups in `~/digidisplay-backups/` instead of beside the config in `~`, so the home folder stays clean. Messages print paths with `~`, because Aurora's `/var/home/<user>` looked like a subfolder when the user is named `digidisplay`.
- **Idle behaviour.** Terminal passes `idle_return=<seconds>` to the website, which does the reset. Workstation locks the screen after `idle_lock_minutes`.
- **Removed.** `version`, `group_id`, `update.automatic`, `remote_admin.tailscale`, `remote_admin.nomachine`, `virtual_keyboard.always_show`, `local.project_path`, `local.docker_path`, `local.ssh_key`, `local.health_url`, the automated runtime test, and the old install/recovery docs (folded into the README and feature docs).

## Why

The client is being prepared for sale. Setup should be "init or login, then apply", and a broken box should be replaced by plugging in a new one and logging in. The previous docs and config had grown by development phase and were hard to follow.

Existing devices are not migrated: they are re-initialised or reflashed. This is MVP work, so verification is manual (see each feature doc's Testing section).

Planning notes: `docs/todos/2026-10-22-major-refactor.md`.
