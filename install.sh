#/bin/sh
SCRIPT_DIR=~/.dotfiles
nix-shell -p git --command "git clone https://github.com/marquessv/nixos-config $SCRIPT_DIR"
sudo nixos-generate-config --show-hardware-config > $SCRIPT_DIR/system/hardware-configuration.nix
sudo nixos-rebuild switch --extra-experimental-features flakes --flake $SCRIPT_DIR#system;
nix run home-manager/master --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake $SCRIPT_DIR#jefe;
