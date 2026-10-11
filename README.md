# Nix Flakes

The `wsl` profile is a minimal development environment for this NixOS-WSL
installation, with user `j`, Fish, Helix, Git, direnv, Nix development tools,
and the extended CLI package set. Fish and Helix use Catppuccin Mocha colors.

Build it from the repository root:

```sh
nix build --extra-experimental-features 'nix-command flakes' --no-write-lock-file 'path:.#nixosConfigurations.wsl.config.system.build.toplevel'
```

Prepare it for the next WSL startup (without switching the running session):

```sh
sudo nixos-rebuild boot --flake 'path:.#wsl'
```

After the boot rebuild, exit this shell and run the username migration sequence
from PowerShell (substitute the registered distribution name if different):

```powershell
wsl --terminate NixOS
wsl --distribution NixOS --user root exit
wsl --terminate NixOS
wsl --distribution NixOS
```

This follows the [NixOS-WSL username-change guide](https://nix-community.github.io/NixOS-WSL/how-to/change-username.html).
The final shell should log in as `j`. Files under `/home/nixos` are not migrated
by this profile.
