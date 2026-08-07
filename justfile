set shell := ["bash", "-uc"]

_default:
    @just --list

digidisplay:
    @bash scripts/digidisplay-bootstrap

digidisplay-status:
    @bash scripts/digidisplay-status

digidisplay-cancel:
    @bash scripts/digidisplay-cancel

digidisplay-launch:
    @bash scripts/digidisplay-launch

digidisplay-tailscale:
    @bash scripts/digidisplay-tailscale
