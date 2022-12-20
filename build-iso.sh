#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-output-monitor
CURRENT_DIR=$(dirname -- "$0")
nix flake update "$CURRENT_DIR"
nom build "${CURRENT_DIR}#nixosConfigurations.iso.config.system.build.isoImage"
