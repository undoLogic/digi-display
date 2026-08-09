# DigiDisplay — Local Docker Offline Mode

## Purpose

This document defines the Phase 2 local/offline runtime feature and records the implemented behavior.

The goal of Phase 2 is to add a **local/offline runtime** while preserving the core DigiDisplay philosophy:

- Aurora DX remains the immutable host platform.
- DigiDisplay configuration remains explicit and maintainable.
- Nothing should change automatically unless DigiDisplay is explicitly updated.
- Content updates and system/application updates are intentionally separate concerns.
- The device should continue to behave like an appliance, not like a general-purpose desktop.

---

## Review Status

This file is the implementation source of truth for the local Docker/offline feature. The initial programming scope in section 18 is implemented. Branded maintenance states and the broader Definition of Done remain follow-up work.

When revising the implementation, review this document in-place and adjust:

- configuration names;
- command names;
- setup/update flow;
- failure behavior;
- implementation priorities.

Sections 14 and 15 are intentionally kept as future work notes, not Phase 2 blockers.

Implemented commands:

```bash
just digidisplay
just digidisplay-launch
just digidisplay-update
just digidisplay-status
just digidisplay-cancel
```

---

# 1. Core Architecture

The intended stack is:

```text
Hardware
  ↓
Aurora DX
  ↓
DigiDisplay configuration / just recipes
  ↓
Firefox kiosk
  ↓
Cloud website OR local Docker runtime
```

For local mode:

```text
Aurora DX
  ↓
Docker / Podman runtime
  ↓
Local CakePHP application
  ↓
localhost
  ↓
Firefox kiosk
```

Firefox should not need to know whether the content is remote or local. It simply loads the configured DigiDisplay target URL.

---

# 2. Cloud Mode vs Local Mode

Add a deployment mode in the DigiDisplay configuration.

The current DigiDisplay config is JSON at:

```text
~/digidisplay.json
```

Example concept:

```json
{
  "mode": "cloud"
}
```

or:

```json
{
  "mode": "local"
}
```

## Cloud mode

Cloud mode remains the simplest configuration.

Example:

```json
{
  "mode": "cloud",
  "url": "https://display.example.com"
}
```

Firefox kiosk launches the configured remote URL.

No local Docker application is required.

## Local mode

Local mode runs a complete local application stack.

Example concept:

```json
{
  "mode": "local",
  "url": "http://localhost",
  "local": {
    "repository": "git@github.com:example/private-project.git",
    "branch": "main",
    "project_path": "~/DigiDisplay/projects/client-project",
    "docker_path": "docker-wsl",
    "ssh_key": "~/.ssh/digidisplay",
    "health_url": "http://localhost/"
  }
}
```

The exact schema can evolve, but the configuration must contain enough information to:

1. locate the application repository;
2. authenticate to it if private;
3. locate the Docker/Compose definition inside the repository;
4. start the local application;
5. point Firefox at the local service.

---

# 3. Repository-Based Local Runtime

The local runtime should be reproducible from Git.

The DigiDisplay device should **not** become the source of truth for a project.

The remote Git repository is the source of truth.

The local filesystem is just a working deployment copy.

Example layout:

```text
~/DigiDisplay/
  projects/
    client-project/
      ... cloned repository ...
```

The repository can be public or private.

Private repositories should authenticate using SSH.

---

# 4. SSH Key Handling

Do **not** place private SSH key contents inside the DigiDisplay configuration file.

Keys should live in the standard SSH location.

Example:

```text
~/.ssh/digidisplay
~/.ssh/digidisplay.pub
```

Recommended permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/digidisplay
chmod 644 ~/.ssh/digidisplay.pub
```

The configuration should only reference the key path.

Example:

```json
{
  "ssh_key": "~/.ssh/digidisplay"
}
```

If a private GitHub repository is used, prefer a dedicated deploy key rather than a developer's general-purpose personal SSH key.

---

# 5. Docker Path Configuration

The local application repository may already have an established Docker structure.

Do not require DigiDisplay projects to adopt a new directory layout if an existing one already works.

Instead, make the path configurable.

Example:

```json
{
  "docker_path": "docker-wsl"
}
```

Even if the directory is historically named `docker-wsl`, DigiDisplay should treat it only as a filesystem path.

It does not matter that Aurora is Linux rather than Windows if the Compose configuration itself is portable.

The implementation should:

1. clone/update the repository;
2. change directory into the configured Docker path;
3. run the appropriate Compose startup command;
4. verify the expected local service responds.

---

# 6. Explicit Updates Only

A major design decision:

**Do not automatically pull application/system changes on boot.**

The system should remain unchanged indefinitely unless an administrator intentionally triggers an update.

This is consistent with Aurora's immutable philosophy and is especially important for digital signage where stability is more valuable than automatic change.

The application itself may already contain its own content synchronization logic. That is separate.

## Two update classes

### Content update

Handled automatically by the application / UpdateCase.

Examples:

- images;
- text;
- schedules;
- presentation content;
- client data.

These updates should not require replacing the local application environment.

### DigiDisplay/application update

Triggered explicitly by an administrator.

Example:

```bash
just digidisplay-update
```

This may change:

- application code;
- Docker definitions;
- dependencies;
- local runtime configuration;
- kiosk configuration;
- DigiDisplay scripts.

This update is intentionally **not automatic**.

---

# 7. Proposed `digidisplay-update` Workflow

Conceptual sequence:

```text
Administrator runs:

just digidisplay-update

        ↓

Show branded "Updating" state

        ↓

Stop / close Firefox kiosk

        ↓

Fetch latest application repository

        ↓

Update / recreate Docker containers

        ↓

Verify localhost application is healthy

        ↓

Show branded "Starting" state

        ↓

Launch Firefox kiosk

        ↓

Return to normal DigiDisplay state
```

## Git behavior

If the repository does not exist locally:

```bash
git clone ...
```

If it already exists:

```bash
git fetch
```

followed by an explicit update strategy.

For appliance-style deployments, consider avoiding a plain unconstrained `git pull` long-term.

A safer future approach could be:

```text
fetch
checkout configured branch/tag/commit
reset --hard to expected revision
```

This would make the local deployment deterministic and prevent local drift.

For the first Phase 2 implementation, a simple pull-based workflow is acceptable if clearly documented.

---

# 8. Docker Update Behavior

After pulling the updated project, the runtime should be recreated from the repository definition.

Conceptually:

```bash
docker compose down
docker compose pull
docker compose up -d --build
```

The exact command depends on the project's existing Compose structure.

Do not assume every update requires deleting persistent volumes.

Persistent application data and databases must be treated separately from disposable containers.

Important distinction:

```text
Containers = disposable runtime
Volumes / application state = persistent data
```

Phase 2 should avoid automatically destroying database volumes.

---

# 9. Localhost Health Check

Before Firefox is relaunched, DigiDisplay should verify that the local application is actually available.

Example concept:

```bash
curl --fail http://localhost/health
```

or, initially:

```bash
curl --fail http://localhost/
```

Recommended behavior:

- Retry for a defined period.
- Show a startup wallpaper/status while waiting.
- Only launch Firefox after the service responds successfully.
- If startup fails, leave a clear visual error state rather than opening a broken browser page.

---

# 10. Visual Update / Maintenance States

DigiDisplay should use the entire desktop as a branded status surface during maintenance.

Instead of exposing terminals, logs, or a blank desktop, swap the KDE wallpaper depending on state.

Suggested assets:

```text
assets/status/
  ready.png
  updating.png
  downloading.png
  starting.png
  error.png
  maintenance.png
```

Example update sequence:

```text
Normal kiosk
   ↓
"Updating DigiDisplay..."
   ↓
"Downloading latest version..."
   ↓
"Starting DigiDisplay..."
   ↓
Firefox kiosk
```

This should be implemented through a reusable helper/recipe rather than hardcoding wallpaper changes throughout scripts.

Possible conceptual command:

```bash
just digidisplay-wallpaper updating
just digidisplay-wallpaper starting
just digidisplay-wallpaper error
just digidisplay-wallpaper ready
```

The implementation should use KDE-native mechanisms appropriate for Aurora/KDE.

---

# 11. Firefox During Updates

During a DigiDisplay application update:

- close all existing kiosk Firefox instances;
- switch to the appropriate branded status wallpaper;
- perform the update;
- verify the local service;
- relaunch Firefox in kiosk mode.

Do not leave stale Firefox processes displaying the previous application while the underlying local runtime is being replaced.

---

# 12. Offline Operation Philosophy

Offline/local mode is not required for every DigiDisplay deployment.

It should be treated as an **optional resilience feature**, not as the only architecture.

Cloud mode remains appropriate for:

- reliable business internet;
- simple deployments;
- installations where real-time remote content is preferred.

Local mode becomes valuable for:

- unreliable connectivity;
- locations where signage must continue during outages;
- high-value installations where uptime matters;
- controlled environments;
- deployments with significant local media.

The architecture should support both without duplicating the entire system.

---

# 13. On-Screen Keyboard / Interactive Kiosk Direction

Aurora KDE's virtual keyboard can support future interactive DigiDisplay installations.

DigiDisplay should eventually support a kiosk-specific keyboard profile with only safe keys.

Desired public keyboard:

```text
A-Z
0-9
Space
Backspace
Enter
basic punctuation
```

Keys to avoid on the public on-screen keyboard:

```text
Ctrl
Alt
Super/Meta
Esc
F1-F12
```

A physical USB keyboard remains the administrator escape hatch and provides full keyboard functionality.

This is a future phase, but configuration should avoid decisions that make it difficult later.

---

# 14. Hardware / Display Diagnostics

Recent testing showed an old monitor only exposed 1024x768 even though the Intel HD Graphics 530 GPU supported much higher resolutions.

After switching monitors, higher resolution worked correctly.

Therefore, DigiDisplay should eventually include hardware diagnostics rather than blindly forcing resolutions.

Possible future command:

```bash
just digidisplay-doctor
```

Potential checks:

- Aurora version;
- network connectivity;
- GPU detected;
- hardware acceleration;
- monitor/output detected;
- highest available resolution;
- Firefox installed;
- kiosk configuration;
- Docker/Podman availability;
- local application health.

Example warning:

```text
WARNING: Highest reported display mode is 1024x768.
Check monitor, cable, adapter, or EDID detection.
```

Do not automatically force unsupported modes.

---

# 15. VM-Based QA

DigiDisplay development should use clean Aurora virtual machines for testing.

Recommended host virtualization stack on Aurora:

```text
KVM
  ↓
libvirt
  ↓
virt-manager
```

Primary QA target:

```text
Aurora DX host
  ↓
Aurora DX VM
  ↓
DigiDisplay
```

Recommended DigiDisplay QA VM baseline:

```text
2 vCPU
4 GB RAM
40 GB qcow2 disk
UEFI / OVMF
VirtIO disk/network
```

20 GB was found to be too small for comfortable Aurora installation/update testing.

Create a clean snapshot after installing Aurora but before installing DigiDisplay.

Suggested snapshot:

```text
Fresh Aurora
```

Then repeatedly:

```text
Restore snapshot
→ clone DigiDisplay
→ install/configure
→ reboot
→ verify
→ restore snapshot
```

---

# 16. Relationship to Aurora Updates

DigiDisplay application updates are separate from Aurora OS updates.

Do not automatically update Aurora as part of `digidisplay-update` unless explicitly requested in the future.

Aurora updates should remain deliberate because signage should not change unexpectedly.

The design goal remains:

> If nobody performs maintenance, the appliance continues running exactly as it is.

---

# 17. Suggested Configuration Shape

This is the proposed first implementation shape for `~/digidisplay.json`.

```json
{
  "version": 1,
  "mode": "local",
  "url": "http://localhost",
  "kiosk": true,
  "wait_for_network": false,
  "restart_browser": true,
  "local": {
    "repository": "git@github.com:example/private-project.git",
    "branch": "main",
    "ssh_key": "~/.ssh/digidisplay",
    "project_path": "~/DigiDisplay/projects/client-project",
    "docker_path": "docker-wsl",
    "health_url": "http://localhost/"
  },
  "update": {
    "automatic": false
  },
  "branding": {
    "wallpaper_ready": "assets/status/ready.png",
    "wallpaper_updating": "assets/status/updating.png",
    "wallpaper_starting": "assets/status/starting.png",
    "wallpaper_error": "assets/status/error.png"
  }
}
```

Cloud example:

```json
{
  "version": 1,
  "mode": "cloud",
  "url": "https://display.example.com",
  "kiosk": true,
  "wait_for_network": true,
  "restart_browser": true,
  "update": {
    "automatic": false
  }
}
```

---

# 18. Phase 2 Implementation Priorities

Implement Phase 2 incrementally.

Recommended order:

1. Add configuration support for `mode: cloud|local`.
2. Add local repository configuration.
3. Add SSH key path support without embedding secrets.
4. Add configurable Docker/Compose project path.
5. Add local runtime start command.
6. Add localhost health check.
7. Add Firefox relaunch against localhost.
8. Add `digidisplay-update`.
9. Add branded update/start/error wallpapers.
10. Add failure handling and useful CLI output.
11. Add VM QA documentation/checklist.
12. Later add `digidisplay-doctor`.

Do not build all future functionality at once.

## Phase 2 Initial Programming Scope

The first implementation should be limited to:

1. Update setup/config handling for `mode`.
2. Support local mode fields under `local`.
3. Clone the configured repository if missing.
4. Update the repository only when `just digidisplay-update` is run.
5. Start the configured Docker Compose runtime.
6. Wait for `local.health_url`.
7. Launch Firefox at the configured local URL.
8. Keep cloud mode working exactly as it does today.

The first implementation should not:

- automatically pull application code on boot;
- delete Docker volumes;
- force display resolutions;
- implement the future on-screen keyboard work;
- require VM automation before the basic local workflow exists.

---

# 19. Design Principles for Codex

When modifying DigiDisplay, preserve these principles:

- Prefer simple Bash/Just recipes over adding unnecessary services.
- Do not create automatic behavior that changes a deployed kiosk unexpectedly.
- Keep content synchronization independent from application/system deployment.
- Keep secrets outside version-controlled configuration.
- Treat Git as the source of truth for the local application deployment.
- Treat Docker containers as disposable.
- Never automatically delete persistent database volumes.
- Prefer explicit, deterministic updates.
- Make maintenance visually understandable on the physical display.
- Keep cloud mode simple.
- Keep local/offline mode optional.
- Preserve compatibility with Aurora DX as the primary supported host.

---

# Phase 2 Definition of Done

Phase 2 is successful when a clean Aurora DX machine can be configured for local mode and the following workflow works reliably:

```text
Install DigiDisplay
      ↓
Clone configured private application repository
      ↓
Start local Docker application
      ↓
Verify localhost responds
      ↓
Launch Firefox kiosk to localhost
      ↓
Disconnect Internet
      ↓
DigiDisplay continues functioning
```

And an administrator can later run:

```bash
just digidisplay-update
```

which:

```text
Shows branded maintenance state
→ updates the application repository
→ recreates the Docker runtime
→ validates localhost
→ restarts Firefox kiosk
→ returns to normal operation
```

without requiring DigiDisplay to automatically alter itself during ordinary boots or content updates.
