set shell := ["bash", "-uc"]

_default:
    @just --list

digidisplay-pull group_id="":
    @bash scripts/digidisplay-pull {{quote(group_id)}}

digidisplay-apply:
    @bash scripts/digidisplay-apply

digidisplay-status:
    @bash scripts/digidisplay-status

digidisplay-cancel:
    @bash scripts/digidisplay-cancel

digidisplay-run:
    @bash scripts/digidisplay-run

digidisplay-launch:
    @bash scripts/digidisplay-launch

digidisplay-update:
    @bash scripts/digidisplay-update

digidisplay-tailscale:
    @bash scripts/digidisplay-tailscale

digidisplay-activate-rdp:
    @bash scripts/digidisplay-activate-rdp

digidisplay-activate-ssh:
    @bash scripts/digidisplay-activate-ssh

test:
    @bash tests/digidisplay-runtime-test
