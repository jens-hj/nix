{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    srv.k3s.agent.enable = lib.mkEnableOption "enables k3s to work as a worker";
  };

  config = lib.mkIf config.srv.k3s.agent.enable {
    services.k3s = {
      enable = true;
      role = "agent";
      serverAddr = "https://192.168.0.125:6443";
      tokenFile = "/var/lib/k3s/token";
    };

    networking.firewall = {
      allowedUDPPorts = [8472]; # flannel VXLAN
    };

    environment.systemPackages = with pkgs; [kubectl];
  };
}
