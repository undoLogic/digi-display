# DigiDisplay: Login, Tokens and Configs (MVP decisions, 2026-10-22)

> **Client note:** pull is implemented as `POST /digiDisplayConfigure`, not GET, because it updates the box's hostname and `last_pulled_at` on the server. State-changing requests are never GET. The box sends `{"hostname": "<current hostname>"}` as JSON on both login and pull.

## Summary
Each box gets its own token at login. Configs live on the server and are
assigned to boxes. On every pull the server returns the assigned config with
the requesting box's own token written into it, so all boxes on the same
config get identical files except for the token. Pull stays a straight
file swap.

## Tokens (one per box)
- Every `digidisplay login` creates a NEW token. One login = one box.
- The token identifies the box. It does not identify the customer or the config.
- Revoking a token cuts off only that box.

## Server

### Table 1: Configs ("DigiDisplay configs", CRUD page)
- Holds all config keys (profile, mode, url, local repo details, deploy key, etc.).
- A customer must have at least one config. No config = error.
- If a customer has several configs, one is marked default; new logins use it.
- Deleting a config that still has boxes assigned: block it (or move those
  boxes to the default).

### Table 2: Active boxes ("DigiDisplay Actives", CRUD index page)
- One row per token: token, config_id, hostname, last_pulled_at.
- Tokens link to a config_id (not directly to the customer), so multiple configs
  per customer later is just more rows.
- Admin can reassign a box to a different config; the box picks it up on its next pull.

### Pull endpoint
1. Box sends its token + current hostname.
2. Server looks up the token → gets config_id.
3. Server overwrites the hostname field and sets last_pulled_at = now.
4. Server returns that config's JSON with the token taken FROM THE REQUEST
   inserted into it. Never insert a token stored on the config or group.
- Validate hostname server-side (letters, numbers, hyphens only) before saving
  or displaying it.
- Requires a valid TLS certificate. Remove `--insecure` on the client before
  login goes live.

## Client (box)

### login
- Asks for email + password once on the CLI (no browser).
- Sends credentials + current hostname; server creates a token row assigned
  to the customer's default config.
- Then runs pull.
- Never stores the password.

### pull
- Sends token + current hostname.
- Receives full config (including its own token) and replaces
  `~/digidisplay.json` as a straight file swap, after the usual timestamped backup.
- No other check-ins: pull is the only time the box talks to the server.

### Security
- `~/digidisplay.json` and all timestamped backups contain the token and deploy
  key, so set them to owner-only (chmod 600).
- README: warn not to share the config file.
- Spec update: the old rule "no secrets in the JSON" is replaced by this
  deliberate MVP exception.

## Deferred (not MVP)
- Separate check-ins / heartbeats beyond pull.
- Hostname drift handling (the latest pulled hostname simply overwrites).
- Full multi-config UI beyond reassigning boxes.
