# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{inputs, ...}: {
  imports = [
    ./hardware.nix
  ];

  home-manager.users.pi = {
    imports = [
      ./home.nix
      inputs.self.outputs.homeManagerModules.default
      inputs.self.outputs.homeManagerModules.linux
      inputs.catppuccin.homeModules.catppuccin
      inputs.stylix.homeModules.stylix
      inputs.vicinae.homeManagerModules.default
      inputs.noctalia.homeModules.default
      inputs.zen-browser.homeModules.beta
    ];
  };

  srv.clusterNode.enable = true;

  # Boot loader
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "rp4j";

  system.stateVersion = "26.05";
}
