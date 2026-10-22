# Remote Admin

**Status:** Implemented.

Remote access is off by default. Nothing opens a public listener unless the config or a command asks for it, and no firewall rules are changed.

## SSH

`"remote_admin": {"ssh": true}` makes `apply` run `sudo systemctl enable --now sshd.service`. Keep SSH limited to trusted networks.

## RDP

`"remote_admin": {"rdp": true}` makes `apply` install a fix for KDE's RDP server. KRDP ships `NoNewPrivileges=true`, which blocks the SELinux transition PAM needs to check passwords, so every RDP login fails. Apply writes `/etc/systemd/user/app-org.kde.krdpserver.service.d/override.conf` with `NoNewPrivileges=false` and restarts KRDP. RDP itself is still turned on in System Settings.

## One-way settings

`ssh` and `rdp` only switch things on. Setting them back to `false` does not disable SSH or remove the RDP fix. To undo by hand:

```bash
sudo systemctl disable --now sshd.service
sudo rm -rf /etc/systemd/user/app-org.kde.krdpserver.service.d
```

## Tailscale

Separate from the config, and opt-in:

```bash
just tailscale
```

It checks that Tailscale is installed, enables `tailscaled`, shows the status, and offers to run `sudo tailscale up`.

## Testing

### Remote access

**Intent:** Remote access exists only when asked for.

**Surfaces:**
- `scripts/digidisplay-apply` (`enable_ssh`, `enable_rdp_fix`)
- `scripts/digidisplay-tailscale`

#### Scenarios

- [ ] With defaults, `apply` leaves `sshd` disabled and installs no KRDP override.
- [ ] `"ssh": true` makes `ssh user@device` work after apply.
- [ ] `"rdp": true` lets an RDP client log in with the user's password.
- [ ] `just tailscale` without Tailscale installed prints install instructions and exits.
