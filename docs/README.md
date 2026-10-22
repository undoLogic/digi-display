# DigiDisplay Docs

Every file here is short and covers one topic, so any of them can be read or discussed on its own.

## Index

| File | Covers |
| --- | --- |
| [overview.md](overview.md) | What DigiDisplay is, architecture, principles, open-core boundary |
| [profiles/signage.md](profiles/signage.md) | Digital signage profile |
| [profiles/terminal.md](profiles/terminal.md) | Interactive terminal profile |
| [profiles/workstation.md](profiles/workstation.md) | Secure workstation profile |
| [features/config-schema.md](features/config-schema.md) | Every key in `~/digidisplay.json`, defaults, and the override rule |
| [features/login-pull-apply.md](features/login-pull-apply.md) | `init`, `login`, `pull`, `apply`, backups, and the token |
| [features/local-runtime.md](features/local-runtime.md) | Local mode: Git checkout, Docker start script, `update-app` |
| [features/kiosk-browser.md](features/kiosk-browser.md) | Firefox kiosk, display power, menu, on-screen keyboard, idle behaviour |
| [features/remote-admin.md](features/remote-admin.md) | SSH, RDP, and Tailscale |
| [roadmap.md](roadmap.md) | Everything planned but not built |
| [decisions/](decisions/) | History: why things are the way they are, and superseded designs |
| [todos/](todos/) | Working notes for planned changes |

## Rules for keeping the docs current

These rules apply to anyone, person or AI agent, changing this repository.

1. **Feature docs describe the code as it is now.** When behaviour, a command or a config key changes, update the matching file in `features/` or `profiles/` in the same change. A doc that disagrees with the code is a bug.
2. **New ideas go in `roadmap.md`,** not in feature docs. Feature docs never describe unbuilt behaviour.
3. **Record significant changes in `decisions/`**: one short file per decision, saying what changed and why. Superseded designs move there instead of being deleted.

Each feature doc ends with a `## Testing` section listing the manual checks that prove it works.
