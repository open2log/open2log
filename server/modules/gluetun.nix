{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.services.gluetun = {
    enable = lib.mkEnableOption "Gluetun VPN proxy for crawling";

    httpProxyPort = lib.mkOption {
      type = lib.types.port;
      default = 8888;
      description = "HTTP proxy port for crawlers";
    };
  };

  config = lib.mkIf config.services.gluetun.enable {
    # Enable Docker/Podman for running gluetun container
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Gluetun container for VPN proxy
    # This hides the server IP when crawling grocery store websites
    virtualisation.oci-containers.containers.gluetun = {
      image = "qmcgaw/gluetun:latest";

      environment = {
        # Configure your VPN provider here
        # VPN_SERVICE_PROVIDER = "mullvad"; # or protonvpn, nordvpn, etc.
        # VPN_TYPE = "wireguard";
        # These should come from SOPS secrets
        TZ = "UTC";
        HTTPPROXY = "on";
        HTTPPROXY_LOG = "on";
      };

      ports = [
        "127.0.0.1:${toString config.services.gluetun.httpProxyPort}:8888"
      ];

      # VPN needs these capabilities
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun"
      ];

      # Mount secrets for VPN configuration
      volumes = [
        "/var/lib/gluetun:/gluetun"
      ];
    };

    # Create data directory
    systemd.tmpfiles.rules = [
      "d /var/lib/gluetun 0700 root root -"
    ];
  };
}
