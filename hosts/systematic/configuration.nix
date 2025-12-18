{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    helix
    wget
  ];

  home-manager.users.j = {
    imports = [
      ./home.nix
      inputs.self.outputs.homeManagerModules.default
      inputs.catppuccin.homeModules.catppuccin
      inputs.stylix.homeModules.stylix
    ];
  };

  wsl.enable = true;
  wsl.defaultUser = "j";

  programs = {
    fish.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        xorg.libX11
        xorg.libXext
        xorg.libXi
        xorg.libXrender
        xorg.libXtst
        xorg.libXrandr
        freetype
        fontconfig
      ];
    };
  };

  visuals.theme.enable = lib.mkForce false;

  nixpkgs.config.allowUnfree = true;
  nix = {
    # package = pkgs.nixFlakes;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [ "https://cache.nixos.org" ];
    };
  };

  # Create symlink from /mnt/c/Users/<myuser>/repos to ~/repos
  systemd.tmpfiles.rules = [ "L /home/j/win-repos - - - - /mnt/c/Users/jjs/clones" ];

  security.pki = {
    installCACerts = true;
    certificateFiles = [
      /home/j/repos/nix/hosts/systematic/sse_issuing_256.pem
      /home/j/repos/nix/hosts/systematic/sse_root_256.pem
    ];
  };

  environment.variables = {
      JAVA_TOOL_OPTIONS = "-Djavax.net.ssl.trustStore=${
          let
            caBundle = config.environment.etc."ssl/certs/ca-certificates.crt".source;
            p11kit = pkgs.p11-kit.overrideAttrs (oldAttrs: {
              mesonFlags = [
                "--sysconfdir=/etc"
                (lib.mesonEnable "systemd" false)
                (lib.mesonOption "bashcompdir" "${placeholder "bin"}/share/bash-completion/completions")
                (lib.mesonOption "trust_paths" (lib.concatStringsSep ":" [ "${caBundle}" ]))
              ];
            });
          in
          derivation {
            name = "java-cacerts";
            builder = pkgs.writeShellScript "java-cacerts-builder" ''
              ${p11kit.bin}/bin/trust \
                extract \
                --format=java-cacerts \
                --purpose=server-auth \
                $out
            '';
            system = builtins.currentSystem;
          }
        } -Djavax.net.ssl.trustStorePassword=changeit";
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
