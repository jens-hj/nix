# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, ... }:
let tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
in {
  imports = [ # Include the results of the hardware scan.
    # include NixOS-WSL modules
    # <nixos-wsl/modules>
  ];


  users.users.nixos = { shell = pkgs.fish; };

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  programs = {
    fish.enable = true;
    nix-ld.enable = true;
    # java.enable = true;
  };

  nix = {
    # package = pkgs.nixFlakes;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters =
        [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [ "https://cache.nixos.org" ];
    };
  };

  # Create symlink from /mnt/c/Users/<myuser>/repos to ~/repos
  systemd.tmpfiles.rules =
    [ "L /home/nixos/clones - - - - /mnt/c/Users/jjs/clones" ];

  nix.registry."node".to = {
    type = "github";
    owner = "andyrichardson";
    repo = "nix-node";
  };

  security.pki = {
    installCACerts = true;
    certificateFiles = [ ./sse_issuing_256.pem ./sse_root_256.pem ];
  };

  # environment.etc."ssl/certs/SSERoot.pem".source = "./sse_root_256.cer";
  # environment.etc."ssl/certs/SSEIssuer.pem".source = "./sse_issuing_256.cer";
  environment.variables = {
    # JAVA_HOME = ""
    JAVAX_NET_SSL_TRUSTSTORE = let
      caBundle = config.environment.etc."ssl/certs/ca-certificates.crt".source;
      p11kit = pkgs.p11-kit.overrideAttrs (oldAttrs: {
        mesonFlags = [
          "--sysconfdir=/etc"
          (lib.mesonEnable "systemd" false)
          (lib.mesonOption "bashcompdir"
            "${placeholder "bin"}/share/bash-completion/completions")
          (lib.mesonOption "trust_paths"
            (lib.concatStringsSep ":" [ "${caBundle}" ]))
        ];
      });
    in derivation {
      name = "java-cacerts";
      builder = pkgs.writeShellScript "java-cacerts-builder" ''
        ${p11kit.bin}/bin/trust \
          extract \
          --format=java-cacerts \
          --purpose=server-auth \
          $out
      '';
      system = builtins.currentSystem;
    };
  };

  # home manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { "nixos" = import ./home.nix; };
  };


  environment.systemPackages = with pkgs; [ helix git zulu11 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
