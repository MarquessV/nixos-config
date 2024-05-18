#/bin/sh

SCRIPT_DIR=~/.dotfiles

nix-shell -p git --command "git clone https://github.com/marquessv/nixos-config $SCRIPT_DIR"

sudo nixos-generate-config --show-hardware-config > $SCRIPT_DIR/system/hardware-configuration.nix

sudo $SCRIPT_DIR/harden.sh $SCRIPT_DIR;

sudo nixos-rebuild switch --flake $SCRIPT_DIR#system;

sed -i "0,marquess/s//$(whoami)"
sed -i "0,Marquess/s//$(getent passwd $(whoami) | cut -d ':' -f 5 | cut -d ',' -f 1/" $SCRIPT_DIR/flake.nix

nix run home-manager/master --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake $SCRIPT_DIR#user;
