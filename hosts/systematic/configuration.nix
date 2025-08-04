{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  environment.systemPackages = with pkgs; [helix wget];

  home-manager.users.jens = {
    imports = [
      ./home.nix
      inputs.self.outputs.homeManagerModules.default
      inputs.catppuccin.homeModules.catppuccin
    ];
  };

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  programs.fish.enable = true;

  nix = {
    # package = pkgs.nixFlakes;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      substituters = ["https://cache.nixos.org" "https://nix-community.cachix.org"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = ["https://cache.nixos.org"];
    };
  };

  # Create symlink from /mnt/c/Users/<myuser>/repos to ~/repos
  systemd.tmpfiles.rules = ["L /home/nixos/clones - - - - /mnt/c/Users/jjs/clones"];

  security.pki = {
    installCACerts = true;
    certificateFiles = [./sse_issuing_256.pem ./sse_root_256.pem];
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
            (lib.concatStringsSep ":" ["${caBundle}"]))
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
      };
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
