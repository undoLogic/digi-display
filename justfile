set shell := ["bash", "-uc"]

_default:
    @just --list

# Create a basic local config: just init [signage|terminal|workstation] [--advanced]
init *args:
    @bash scripts/digidisplay-init {{args}}

# Log in to DigiDisplay cloud, save the device token, then pull
login:
    @bash scripts/digidisplay-login

# Re-fetch this device's config from the cloud (overwrites local edits; keeps a backup)
pull:
    @bash scripts/digidisplay-pull

# Make this device match the config
apply:
    @bash scripts/digidisplay-apply

# Show final settings, where each came from, and the kiosk logs
status:
    @bash scripts/digidisplay-status

# Update the local-mode Docker app (never runs automatically)
update-app:
    @bash scripts/digidisplay-update-app

# Troubleshooting: run the kiosk in the foreground
launch:
    @bash scripts/digidisplay-launch

# Troubleshooting: stop the kiosk and close Firefox
cancel:
    @bash scripts/digidisplay-cancel

# Optional: enable Tailscale remote access
tailscale:
    @bash scripts/digidisplay-tailscale
