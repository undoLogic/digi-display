# Local Runtime

**Status:** Implemented.

In local mode the app runs in Docker on the box, so the screen keeps working without internet. The cloud is still the source of content; the local copy is only a working deployment.

## Config

```json
{
  "profile": "signage",
  "mode": "local",
  "local": {
    "repository": "git@github.com:example/client-project.git",
    "branch": "main",
    "deploy_key": "-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----"
  }
}
```

`url` defaults to `http://localhost`. It is both the page Firefox opens and the readiness check.

## Fixed conventions

| What | Where |
| --- | --- |
| App checkout | `~/digidisplay-webroot` (beside `~/digi-display`, not inside it) |
| Start script | `dockerLinux/1startDocker.sh` in the app repository (SetupCase Core convention) |
| Deploy key file | `~/.ssh/digidisplay-deploy-key`, written by `apply` from `local.deploy_key`, mode 600 |

Projects must provide `dockerLinux/1startDocker.sh`. DigiDisplay runs it from inside `dockerLinux/` and expects it to return once the containers are started.

## On every kiosk start

1. Clone `local.repository` at `local.branch` into `~/digidisplay-webroot`, only if it is missing.
2. Run `dockerLinux/1startDocker.sh`.
3. Poll `url` every 2 seconds, up to 60 times.
4. Open Firefox. If the app never answers, the kiosk stays closed and the error is in the log.

An existing checkout is never updated on start.

## `just update-app`

The only command that changes the app code:

1. Stop the kiosk and close Firefox.
2. Refuse if the checkout has tracked local changes.
3. Fetch `local.branch` and fast-forward only.
4. Run the start script, then wait for `url`.
5. Start the kiosk. On any failure the kiosk stays closed.

Docker volumes are never deleted. Nothing important should exist only in them.

## Deploy keys

- Use one read-only GitHub deploy key per customer repository.
- The first connection to the Git host accepts its SSH host key automatically (`StrictHostKeyChecking=accept-new`), so no manual `ssh` step is needed on a new box.
- Removing `local.deploy_key` from the config and running `apply` deletes the key file.

## Testing

### Local start

**Intent:** A box in local mode starts its app from Git and only shows it once it answers.

**Surfaces:**
- `scripts/lib/digidisplay-local-runtime`
- `scripts/digidisplay-launch`

#### Scenarios

- [ ] With no `~/digidisplay-webroot`, the kiosk start clones the repository and runs `dockerLinux/1startDocker.sh`.
- [ ] A private repository clones using `local.deploy_key` with no manual SSH setup.
- [ ] Firefox opens only after `url` answers.
- [ ] If the app never answers, Firefox does not open and `just status` shows the error.
- [ ] A repository without `dockerLinux/1startDocker.sh` fails with a message naming the missing script.
- [ ] Rebooting does not fetch new commits.
- [ ] With the network unplugged after setup, a reboot still shows the app.

### Update app

**Intent:** App code changes only on request, and a failed update never shows a broken app.

**Surfaces:**
- `scripts/digidisplay-update-app`

#### Scenarios

- [ ] `just update-app` fast-forwards to the latest commit and reopens the kiosk.
- [ ] With tracked local changes in the checkout, `update-app` refuses and leaves the code unchanged.
- [ ] In cloud mode, `update-app` says it is only available in local mode.
- [ ] Docker volumes and their data survive an update.
