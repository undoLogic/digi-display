# DigiDisplay configuration pull/apply workflow

## Status and purpose

This is a pre-implementation specification, reconciled with the code currently in this repository.

The goal is to make the device configuration workflow explicit and noninteractive:

```text
server -> pull -> ~/digidisplay.json -> review/edit -> apply -> Aurora device
```

The DigiDisplay device remains a URL runtime. In `cloud` mode Firefox opens a remote URL. In `local` mode the existing runtime prepares a Git-managed Docker Compose application and Firefox opens its configured localhost URL.

This feature must extend that working behavior rather than introduce a second runtime or a replacement schema.

## Current implementation facts

The following are already implemented and are constraints for this work:

- This is the Aurora client repository. It does not contain the UpdateCase/Digi-Display CakePHP application or its routes.
- Repository commands are local `just` recipes. This repository does not currently install system-wide `ujust` recipes.
- The persistent configuration file is `~/digidisplay.json`. All current scripts also support the `DIGIDISPLAY_CONFIG` environment override.
- The current schema version is `1`.
- Supported modes are `cloud` and `local`, not `cloud` and `docker`.
- `local` is already the Docker Compose mode. Its settings live under the `local` object.
- `scripts/digidisplay-launch` reads the JSON and launches the runtime.
- `scripts/digidisplay-bootstrap` currently asks questions, writes the JSON, and performs machine setup.
- `scripts/digidisplay-update` is the only command that updates an existing local application checkout. Ordinary launch does not pull application code.
- The systemd user unit is `digidisplay.service`.
- Tailscale, SSH activation, RDP activation, status, run, cancel, launch, and local application update already have distinct command concerns.

The new implementation should use the existing names and paths. Examples in this document therefore use `just`, which means they are run from the cloned DigiDisplay repository (normally `~/digi-display`). Packaging these recipes as system-wide `ujust` commands can be considered separately.

## Command model

Add these repository recipes:

```bash
just digidisplay-pull
just digidisplay-pull 123
just digidisplay-apply
```

The intended administrator workflow is:

```bash
cd ~/digi-display
just digidisplay-pull 123
nano ~/digidisplay.json
just digidisplay-apply
```

`pull` and `apply` must remain separate:

- `digidisplay-pull` retrieves, validates, and atomically stores configuration. It makes no system or runtime changes.
- `digidisplay-apply` reads the current local file, validates it, applies the represented machine settings, installs/updates the user service, and makes the selected runtime active. It does not contact the Digi-Display server.

This separation permits review, local edits, offline reapplication, and Community Edition use without a cloud account.

## Configuration contract

### Location

The active file remains:

```text
~/digidisplay.json
```

This path is in the mutable home directory and survives normal Aurora reboots and image updates. New scripts must continue to honor:

```bash
DIGIDISPLAY_CONFIG=/another/path/config.json
```

### Version 1 schema

Do not add a parallel `docker` object or a `mode: "docker"` value. Add `group_id` to the existing version-1 document and preserve the current field names.

A complete cloud configuration is:

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
  "virtual_keyboard": {
    "always_show": false
  },
  "remote_admin": {
    "tailscale": false,
    "ssh": false,
    "nomachine": false
  },
  "update": {
    "automatic": false
  }
}
```

A complete local/Docker configuration is:

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
  "virtual_keyboard": {
    "always_show": false
  },
  "remote_admin": {
    "tailscale": false,
    "ssh": false,
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

The browser always uses top-level `url`. In local mode, `local.health_url` is independently used to decide when the Docker application is ready.

`local.ssh_key` is a local path only. Private key contents, passwords, tokens, and other secrets must never be returned by the unauthenticated group endpoint or stored directly in this JSON.

### `group_id`

`group_id` identifies the server-side group used to produce the configuration:

- An unassigned or locally managed device uses JSON boolean `false`.
- A cloud-managed device uses a positive JSON integer.
- Strings, zero, negative integers, `true`, arrays, and objects are invalid.

Existing installed version-1 files predate this field. For backward compatibility, `digidisplay-apply` must accept a missing `group_id`, treat it as `false`, and atomically normalize the local file to include it. Newly created, downloaded, and example files must always contain the field.

Adding this optional field does not require a schema version bump because it is metadata and does not change existing runtime field meanings.

### Existing fields that are not fully declarative

The version-1 document contains fields that the current implementation only partially acts on:

- `remote_admin.ssh: true` may enable SSH through the existing activation script. `false` does not currently disable an already enabled SSH service.
- `remote_admin.tailscale` and `remote_admin.nomachine` are recorded but are not applied by the bootstrap script.
- `update.automatic` is currently forced to `false`; automatic application or OS updates are not implemented.

The first `digidisplay-apply` implementation must preserve these semantics. It must not silently add destructive disable behavior or automatic management.

Autologin, RDP activation, and reboot are currently interactive bootstrap choices and are not represented in the JSON. They are outside the first `apply` contract. RDP and SSH continue to have their existing explicit recipes. A later schema revision can make additional provisioning state declarative if required.

## `digidisplay-pull`

### Input

The recipe accepts zero or one argument:

```bash
just digidisplay-pull
just digidisplay-pull 123
```

If supplied, the argument must contain ASCII decimal digits and represent a positive integer. Extra arguments or invalid values must fail before making an HTTP request.

### Server requests

The proposed endpoint contract is:

```http
GET /configure
GET /configure/{group_id}
Accept: application/json
```

Examples:

```text
https://site2staging.digi-display.com/configure
https://site2staging.digi-display.com/configure/123
```

The exact route and production base URL must be finalized in the UpdateCase/Digi-Display server repository. They must not be inferred from this client repository. The client implementation should keep the endpoint configurable for staging and tests rather than embedding the example staging hostname throughout the script.

The CakePHP endpoint is a separate cross-repository prerequisite. It should return one complete version-1 configuration object, not a wrapper object and not a partial patch.

For `/configure`, the response must be a usable unassigned default with `group_id: false`. It should use the complete cloud example above unless the server product has another agreed public default URL. Returning an empty `mode` or empty `url` would deliberately produce a file that `apply` rejects and is therefore not the preferred contract.

For `/configure/{group_id}`, the response must contain the same positive integer in `group_id`. A missing group should return an appropriate non-2xx response, preferably `404`, rather than an unassigned configuration.

### Pull validation and replacement

`digidisplay-pull` must:

1. Validate its argument.
2. Download to a temporary file created in the destination file's directory.
3. Require a successful HTTP status.
4. Parse the response as a top-level JSON object.
5. Validate the complete supported schema before replacement.
6. Confirm `group_id` is `false` for a no-argument request or exactly matches the requested integer.
7. Write a final newline and atomically rename the temporary file over `~/digidisplay.json`.
8. Clean up its temporary file on every failure.
9. Print the saved path and tell the administrator to run `just digidisplay-apply`.

Validation before replacement is important. A syntactically valid but unusable response must not destroy a working configuration.

The command must leave the existing local file byte-for-byte unchanged when any of these occur:

- DNS, TLS, connection, timeout, or other transport failure.
- Non-success HTTP response.
- Empty response or invalid JSON.
- JSON with the wrong top-level type.
- Unsupported schema version or mode.
- Missing or invalid required fields.
- A response `group_id` that does not match the request.
- Temporary-file, permission, or rename failure.

`pull` must not apply settings, restart the service, launch Firefox, start Docker, update a local Git checkout, enroll Tailscale, or check the device in anywhere else.

## `digidisplay-apply`

### Responsibility

`digidisplay-apply` replaces the noninteractive, config-backed portion of the current bootstrap flow:

```text
read JSON -> normalize legacy group_id -> validate/preflight -> apply settings -> activate runtime
```

The implementation should extract and reuse functions from `scripts/digidisplay-bootstrap`; it should not duplicate the Firefox, systemd, KDE, hostname, wallpaper, or SSH setup logic in a second independent implementation.

The existing interactive `just digidisplay` command may remain as a convenience/legacy provisioning entry point during migration. If retained, it should write the same schema and call shared apply functions so the two paths cannot drift.

### Validation and preflight

All configuration validation must finish before machine settings are changed. At minimum, require:

- Readable, valid JSON with a top-level object.
- `version` equal to integer `1`.
- A valid `group_id`, including the missing-field legacy rule above.
- `hostname` accepted by the current hostname validator.
- `mode` equal to `cloud` or `local`.
- `url` beginning with `http://` or `https://`.
- Boolean values for `kiosk`, `wait_for_network`, and `restart_browser`.
- `virtual_keyboard.always_show` to be boolean when present.
- Supported `remote_admin` and `update` values to have the expected types.
- `update.automatic` to remain `false` until automatic updates are implemented.

For `local` mode, also require:

- Non-empty `local.repository`.
- Non-empty `local.branch`.
- Non-empty `local.project_path`.
- Non-empty, relative `local.docker_path` that resolves inside `local.project_path`.
- `local.ssh_key` to be a string; it may be empty for public repositories.
- `local.health_url` beginning with `http://` or `https://`.
- Git, Docker, Docker Compose, and curl to be available.

Firefox, Python, and systemd must also be available before application begins. Because this command is noninteractive, a missing dependency must produce an actionable error rather than an installation prompt.

Unknown keys may be preserved for forward compatibility, but unknown modes or incompatible field types must never be silently replaced with fallback values during `apply`.

### Apply behavior

After successful validation and preflight, `digidisplay-apply` should reuse the existing operations to:

1. Configure the hostname.
2. Enable SSH only when the existing `remote_admin.ssh` semantics request it.
3. Install/update the DigiDisplay Firefox profile.
4. Install/update and enable `digidisplay.service`, including its restart policy from `restart_browser`.
5. Configure KDE locking and power management.
6. Configure the Plasma virtual keyboard from `virtual_keyboard.always_show`.
7. Install/apply the DigiDisplay wallpaper.
8. Restart an active kiosk service, or start it if it is installed but inactive, so the new configuration becomes active without requiring a reboot.

If local mode is selected, starting the service invokes the already implemented local runtime: clone the repository only when missing, run `docker compose up -d --build`, wait for `local.health_url`, and then open top-level `url`. `apply` must not fetch or update an existing checkout; `just digidisplay-update` remains the explicit update operation.

Validation prevents malformed configuration from causing partial changes. Machine configuration itself is not transactional, so an operational failure after application begins must stop immediately, report which operation failed, and return nonzero. The command must not claim success or hide the failure.

`apply` must not contact the Digi-Display configuration endpoint, change an existing `group_id` (apart from adding `false` to a legacy file where the field is absent), enroll Tailscale, activate RDP, enable automatic polling, push local configuration to the cloud, or reboot the device.

## Local-only and cloud-managed ownership

### Community/self-managed

A device is fully usable with:

```json
"group_id": false
```

The administrator may create or edit `~/digidisplay.json` directly and run:

```bash
just digidisplay-apply
```

No pull and no Digi-Display account are required. A fresh installation must not automatically register or contact Digi-Display services.

### Cloud-managed

The initial managed workflow is intentionally manual:

```text
customer edits configuration in Digi-Display SaaS
-> administrator runs just digidisplay-pull <group_id>
-> downloaded file atomically replaces local configuration
-> administrator reviews it
-> administrator runs just digidisplay-apply
```

The cloud copy is authoritative only for fields represented in the server response. Local edits are not uploaded. The next successful pull replaces them.

For recovery or device replacement, JSON restoration does not by itself restore external prerequisites such as a private Git deploy key, Git host keys, Docker data/volumes, Tailscale enrollment, or other machine credentials. Those must be provisioned separately.

## Security boundary

Using a predictable `group_id` without authentication is acceptable only as an explicitly temporary, low-security transport for non-sensitive configuration.

- Do not treat `group_id` as a secret or authentication factor.
- Do not return credentials, private keys, tokens, passwords, customer secrets, or other sensitive fields.
- Avoid returning information that should not be publicly enumerable.
- Use HTTPS and fail on certificate errors.
- Add device authentication or signed requests before this endpoint carries sensitive configuration or is treated as a production management channel.

Tailscale remains a separate remote-access concern. Do not use Tailscale identity as DigiDisplay configuration identity in this phase, and do not enroll Tailscale as a side effect of pull or apply.

## Non-goals for this phase

- Installing repository recipes into the system-wide `ujust` catalog.
- Automatic polling or scheduled pulls.
- Automatic check-in or device registration.
- Bidirectional synchronization or pushing local edits.
- Authentication beyond the temporary `group_id` lookup.
- Automatic Aurora OS updates.
- Updating an existing local application checkout during launch or apply.
- A new `docker` mode or a second Docker configuration schema.
- Declarative disabling/removal of SSH, RDP, Tailscale, or NoMachine.
- Moving private keys or other credentials through configuration JSON.

## Required implementation scope

### Aurora client repository

1. Add `scripts/digidisplay-pull` and its optional-argument `just` recipe.
2. Add `scripts/digidisplay-apply` and its `just` recipe.
3. Extract shared validation/application helpers from the current bootstrap where practical.
4. Add `group_id: false` to the example configuration and to JSON written by the interactive path.
5. Preserve `DIGIDISPLAY_CONFIG` support.
6. Update user documentation after the commands exist.
7. Keep all existing runtime commands working.

### UpdateCase/Digi-Display server repository

1. Add the agreed CakePHP JSON route for the default and optional positive group ID.
2. Serialize a complete, supported version-1 DigiDisplay configuration.
3. Return `group_id: false` only for the no-group default request.
4. Return non-2xx for missing/invalid groups and server failures.
5. Exclude secrets and other fields unsuitable for a public, enumerable endpoint.
6. Add endpoint contract tests.

The server work cannot be implemented or verified in this Aurora repository because the CakePHP application is not present here.

## Verification and acceptance criteria

Before this feature is complete, automated tests should prove:

- Pull with no argument accepts a valid default response containing `group_id: false`.
- Pull with a positive group ID accepts only a response with the same ID.
- Invalid, zero, negative, extra, and non-integer arguments fail without a request.
- Network, HTTP, JSON, schema, ID-mismatch, and write failures preserve an existing config byte-for-byte.
- Pull has no systemd, Firefox, Docker, Git-update, Tailscale, RDP, or reboot side effects.
- Apply accepts and normalizes a legacy version-1 file with no `group_id`.
- Apply rejects invalid cloud and local configs before machine mutations.
- Apply is noninteractive.
- Apply installs/enables the user service and activates the selected URL.
- Changing `restart_browser` updates the systemd restart policy.
- Cloud apply does not invoke the local Docker runtime.
- Local apply retains the existing clone-if-missing, Compose start, health-check, and browser behavior.
- Local apply does not update an existing Git checkout.
- The existing `tests/digidisplay-runtime-test` suite continues to pass.

The phase is accepted when this explicit workflow succeeds on Aurora DX:

```bash
cd ~/digi-display
just digidisplay-pull [group_id]
nano ~/digidisplay.json
just digidisplay-apply
```

and the same device can still be configured and operated locally without a Digi-Display cloud account.

## Decisions still required before client/server programming

The repository inspection cannot determine these product/server details:

1. The final CakePHP route and production base URL. The staging URL in this document is illustrative.
2. The public default URL returned by the no-group endpoint, if it should differ from the current `https://www.undologic.com/en/pages/screen` default.
3. Which version-1 fields the unauthenticated server is allowed to expose. The response must still be complete enough to pass client validation.

These decisions do not change the client architecture, but they should be resolved before hard-coding the endpoint contract.
