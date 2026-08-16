# Digi-Display Configuration Workflow — Codex Handoff

## Purpose

This document captures the latest architecture decision for the Digi-Display Aurora client.

The goal is to simplify the device workflow substantially.

The Aurora device should **not** be highly interactive and should **not** contain customer-facing content logic itself.

Its job is primarily to:

1. Store a local JSON configuration.
2. Pull a configuration from the Digi-Display server when requested.
3. Apply the current local configuration to the immutable Aurora system.
4. Ultimately launch URLs, whether those URLs are cloud-hosted or served locally from Docker.

The current interactive configuration workflow should therefore be broken apart into smaller, explicit commands.

---

# Core Principle

The Digi-Display box is a **URL runtime**.

It should ultimately display one of two things:

- A remote/cloud URL.
- A localhost URL served by a Dockerized project running on the device.

Even when Docker is used, the screen itself is still just opening a URL.

The Aurora layer should remain minimal.

---

# New Command Model

The desired command structure is:

```bash
ujust digidisplay-pull
ujust digidisplay-pull <group_id>
ujust digidisplay-apply
```

Naming may be adjusted to match the existing repository conventions, but the behavior should follow this model.

---

# 1. `digidisplay-pull`

## Purpose

Download the Digi-Display configuration JSON from the Digi-Display server and save it locally.

This command should **not** apply the configuration.

It only retrieves and stores the JSON.

---

## Optional Group ID

The command accepts an optional integer:

```bash
ujust digidisplay-pull 123
```

For now, that integer represents the existing server-side `group_id`.

The group ID is intentionally being used as a simple first implementation.

This is **not intended to be the final security model**.

Later it can be replaced or supplemented with:

- Device IDs
- Tokens
- Authentication
- Deployment IDs
- Signed configuration requests

Do not overbuild that security layer yet.

---

## No Group ID

The command must also work with no argument:

```bash
ujust digidisplay-pull
```

If no group ID is provided, the server should return an empty/default configuration.

This allows a Digi-Display device to be provisioned without first creating a customer or associating the device with an account.

That is important.

The system must support:

```text
Generic device
→ local configuration
→ no cloud/customer association required
```

---

# Server Endpoint

Create a simple Digi-Display configuration route in the UpdateCase/Digi-Display server.

Conceptually:

```text
https://site2staging.digi-display.com/configure
```

or:

```text
https://site2staging.digi-display.com/configure/{group_id}
```

The final URL structure should follow existing CakePHP routing conventions.

The endpoint should return JSON only.

Example request:

```text
GET /configure/123
```

Example response:

```json
{
    "group_id": 123,
    "mode": "cloud",
    "url": "https://example.com/display",
    "docker": null
}
```

If no group ID is supplied:

```text
GET /configure
```

Return a default/empty configuration, for example:

```json
{
    "group_id": false,
    "mode": "",
    "url": "",
    "docker": null
}
```

The exact schema can evolve, but the local file must always contain a `group_id` field.

---

# Local Configuration File

The downloaded JSON should be stored as the device's local Digi-Display configuration file.

Use the existing configuration location if one already exists.

If not, Codex should identify an appropriate persistent path that works correctly with Aurora's immutable model.

The important requirement is:

> The configuration must survive normal reboots and system updates.

---

# Local Editing

After pulling the configuration, the administrator should be able to edit it directly.

Example:

```bash
nano /path/to/digidisplay-config.json
```

The previous interactive wizard is no longer the preferred ongoing workflow.

Instead:

```text
Pull JSON
→ edit JSON if necessary
→ apply JSON
```

This is simpler and more transparent.

---

# 2. `digidisplay-apply`

## Purpose

Read the **current local configuration JSON** and apply it to the Aurora system.

This command should reuse the logic that currently exists in the interactive Digi-Display configuration process.

The difference is that the values no longer come from interactive questions.

They come from the JSON file.

Conceptually:

```text
OLD

Ask questions
→ collect answers
→ make system changes
```

becomes:

```text
NEW

Read JSON
→ validate values
→ make system changes
```

---

# Important Separation

`pull` and `apply` must remain separate.

## Pull

```text
Server → local JSON
```

## Apply

```text
Local JSON → system configuration
```

This separation is intentional.

It allows:

- Reviewing a downloaded configuration before applying it.
- Manually editing local configuration.
- Reapplying existing configuration without contacting the server.
- Running Digi-Display completely locally.
- Easier debugging.
- Easier automation later.

---

# Local-Only / Free Model

A Digi-Display device should be completely usable without a Digi-Display cloud account.

The user can:

1. Install/provision Digi-Display.
2. Pull an empty configuration or create/edit the JSON locally.
3. Add their own URL.
4. Run `digidisplay-apply`.
5. Operate the device independently.

In this mode:

```json
"group_id": false
```

The configuration exists only locally.

There is **no expectation that Digi-Display has a cloud backup of it**.

This distinction should be clear in the architecture.

---

# Cloud-Managed Model

If the customer has a Digi-Display account, their configuration can be maintained through the Digi-Display SaaS application.

That application is based on UpdateCase with Digi-Display branding.

The workflow becomes:

```text
Customer edits configuration in Digi-Display SaaS
→ server stores configuration
→ device runs digidisplay-pull <group_id>
→ latest JSON replaces local JSON
→ device runs digidisplay-apply
→ updated configuration becomes active
```

Initially, `pull` can be manual.

Later it may be:

- Scheduled
- Triggered remotely
- Run automatically
- Connected to a device management system

Do not implement automatic polling unless it is already trivial.

---

# Cloud vs Local Configuration Boundary

This distinction is important commercially and technically.

## Local Configuration

If a customer edits the local JSON manually:

```text
Device JSON changes
```

Those changes are **not automatically synchronized back to the Digi-Display cloud**.

There is no bidirectional sync at this stage.

The cloud does not know about those local changes.

This is intentional.

---

## Cloud Configuration

If the customer wants Digi-Display to maintain the authoritative configuration:

```text
Digi-Display SaaS
→ server configuration
→ pull to device
```

The cloud version is the authoritative copy.

That provides the basis for:

- Backup
- Device replacement
- Reprovisioning
- Centralized management
- Managed service
- Future automatic updates

---

# Device Swap / Recovery Relationship

This configuration model directly supports the managed-device replacement concept.

For a managed customer:

```text
Configuration exists in Digi-Display cloud
→ old device fails
→ replacement device is provisioned
→ digidisplay-pull <group_id>
→ digidisplay-apply
→ deployment is restored
```

This is one of the commercial advantages of using Digi-Display's cloud service.

If a customer manages configuration only locally, Digi-Display cannot promise that the latest local-only changes are recoverable from the cloud.

---

# Do Not Automatically Check In

A fresh Community Edition / generic Digi-Display installation should **not automatically register itself with Digi-Display servers**.

There should be no hidden automatic onboarding.

The user/admin deliberately runs:

```bash
ujust digidisplay-pull <group_id>
```

when they want the device associated with a Digi-Display cloud configuration.

This keeps the open/community system independent from the commercial service.

---

# Tailscale

Tailscale remains the preferred remote-management mechanism for managed deployments.

However, Tailscale enrollment is a separate concern from configuration retrieval.

Do not couple:

```text
Tailscale identity
```

directly to:

```text
Digi-Display configuration identity
```

at this stage.

They may be integrated later, but they serve different purposes:

- Tailscale = secure remote access / management.
- Digi-Display config endpoint = application/device configuration.

---

# Initial JSON Schema

Keep the first schema small.

A reasonable starting point is:

```json
{
    "group_id": false,
    "mode": "cloud",
    "url": "",
    "docker": {
        "enabled": false,
        "source": "",
        "local_url": ""
    }
}
```

This is only an example.

Codex should compare it with the fields already used by the current interactive configuration before finalizing the schema.

Reuse existing configuration names where practical rather than inventing a completely new structure.

---

# Expected Runtime Modes

## Cloud URL

```json
{
    "group_id": 123,
    "mode": "cloud",
    "url": "https://client.example.com/signage"
}
```

The browser opens the remote URL.

---

## Local Docker

Future example:

```json
{
    "group_id": 123,
    "mode": "docker",
    "docker": {
        "enabled": true,
        "source": "...",
        "local_url": "http://localhost:8080"
    }
}
```

The system prepares/runs the Docker project.

The browser still only opens:

```text
http://localhost:8080
```

Again, the browser/runtime should not care whether the content originates remotely or locally.

---

# Existing Interactive Configuration

Do **not** throw away working implementation unnecessarily.

Codex should inspect the current configuration script and refactor it.

The existing workflow likely already contains code that:

- Sets kiosk behavior.
- Sets URLs.
- Configures Firefox.
- Starts/restarts required services.
- Handles other Digi-Display system settings.

Extract or reuse those operations behind `digidisplay-apply`.

The interactive question/answer layer should be removed from the normal configuration path.

---

# Validation

`digidisplay-apply` should perform basic validation before changing the system.

Examples:

- JSON is valid.
- Required fields for the selected mode exist.
- `mode=cloud` has a URL.
- `mode=docker` has the required Docker information.
- URLs have an expected scheme.
- Unknown modes produce a useful error.

Do not silently partially apply malformed configuration.

---

# Recommended Command Behavior

## Pull with Group

```bash
ujust digidisplay-pull 123
```

Expected output conceptually:

```text
Fetching Digi-Display configuration for group 123...
Configuration downloaded.
Saved to: /path/to/config.json

Run:
ujust digidisplay-apply

to apply this configuration.
```

---

## Pull Without Group

```bash
ujust digidisplay-pull
```

Expected:

```text
Fetching default Digi-Display configuration...
Default configuration downloaded.
Saved to: /path/to/config.json
```

---

## Apply

```bash
ujust digidisplay-apply
```

Expected:

```text
Reading Digi-Display configuration...
Validating configuration...
Applying Digi-Display settings...
Configuration applied successfully.
```

---

# Error Handling

`pull` should fail cleanly if:

- Server cannot be reached.
- HTTP response is not successful.
- Response is not valid JSON.
- File cannot be written.

Importantly:

> Do not destroy the existing valid local configuration if a pull fails.

Use a temporary file.

Conceptually:

```text
download → validate → replace existing configuration
```

not:

```text
erase current config → attempt download
```

This protects working deployments.

---

# Security Note

Using `group_id` alone is intentionally low security for the first implementation.

Do not treat the group ID as a secret.

Do not place sensitive credentials in the returned JSON while this endpoint is identified only by a predictable integer.

For now the configuration endpoint should contain only low-risk configuration.

Before production cloud-managed deployments containing sensitive values, add proper authentication or device-specific credentials.

---

# Business Model Supported by This Architecture

This workflow cleanly supports two product paths.

## Community / Self Managed

```text
Free image
+ own hardware
+ own/local JSON
+ own URL
```

No Digi-Display cloud service required.

---

## Digi-Display Managed / Cloud

```text
Digi-Display SaaS
+ centralized JSON
+ pull configuration
+ device recovery
+ remote management
+ managed service
```

The commercial value is not locking the device.

The commercial value is:

- Centralized management
- Configuration backup
- Easy reprovisioning
- Support
- Monitoring
- Tailscale management
- Managed content
- Device replacement
- Custom URL/application development

---

# Codex Implementation Request

Please inspect the current Aurora Digi-Display repository and existing interactive configuration implementation before changing code.

Then implement/refactor toward the following:

1. Create `digidisplay-pull`.
2. Make its integer `group_id` argument optional.
3. Create/configure a server endpoint that returns Digi-Display JSON.
4. Store the returned JSON in the existing appropriate persistent config location.
5. Ensure failed pulls do not overwrite a valid existing configuration.
6. Ensure the JSON always contains `group_id`, using `false` when unassigned.
7. Refactor the existing interactive configuration logic into `digidisplay-apply`.
8. `digidisplay-apply` must read configuration from the local JSON instead of asking interactive questions.
9. Keep the first JSON schema as close as practical to the values already supported by the current implementation.
10. Do not introduce automatic cloud check-in.
11. Do not introduce bidirectional sync.
12. Do not tightly couple Tailscale to this configuration system.
13. Preserve Community Edition/local-only operation.
14. Keep the architecture compatible with future Docker/local URL mode.
15. Before making large structural changes, report any conflicts between this plan and the current implementation.

The immediate objective is a simple, explicit workflow:

```bash
ujust digidisplay-pull [group_id]
nano <config-file>
ujust digidisplay-apply
```

That is the desired foundation.
