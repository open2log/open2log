{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.services.open2log = {
    enable = lib.mkEnableOption "open2log Phoenix application";

    port = lib.mkOption {
      type = lib.types.port;
      default = 4000;
      description = "Port for the Phoenix application";
    };

    secretKeyBasePath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the secret key base file";
    };
  };

  config = lib.mkIf config.services.open2log.enable {
    # Create a system user for the application
    users.users.open2log = {
      isSystemUser = true;
      group = "open2log";
      home = "/var/lib/open2log";
      createHome = true;
    };

    users.groups.open2log = { };

    # Systemd service for the Phoenix application
    systemd.services.open2log = {
      description = "open2log Phoenix Application";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        PORT = toString config.services.open2log.port;
        PHX_HOST = "open2log.com";
        MIX_ENV = "prod";
        RELEASE_TMP = "/tmp/open2log";
        # DuckDB database location
        DUCKDB_PATH = "/var/lib/open2log/data.duckdb";
      };

      serviceConfig = {
        Type = "simple";
        User = "open2log";
        Group = "open2log";
        WorkingDirectory = "/var/lib/open2log";
        ExecStart = "/var/lib/open2log/bin/open2log start";
        ExecStop = "/var/lib/open2log/bin/open2log stop";
        Restart = "on-failure";
        RestartSec = "5s";

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [
          "/var/lib/open2log"
          "/tmp/open2log"
        ];

        # Load secrets
        EnvironmentFile = config.services.open2log.secretKeyBasePath;
      };
    };

    # Nginx reverse proxy
    services.nginx = {
      enable = true;

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts."open2log.com" = {
        # Cloudflare handles SSL termination
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
        ];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.open2log.port}";
          proxyWebsockets = true;
          extraConfig = ''
            # Real IP from Cloudflare
            set_real_ip_from 173.245.48.0/20;
            set_real_ip_from 103.21.244.0/22;
            set_real_ip_from 103.22.200.0/22;
            set_real_ip_from 103.31.4.0/22;
            set_real_ip_from 141.101.64.0/18;
            set_real_ip_from 108.162.192.0/18;
            set_real_ip_from 190.93.240.0/20;
            set_real_ip_from 188.114.96.0/20;
            set_real_ip_from 197.234.240.0/22;
            set_real_ip_from 198.41.128.0/17;
            set_real_ip_from 162.158.0.0/15;
            set_real_ip_from 104.16.0.0/13;
            set_real_ip_from 104.24.0.0/14;
            set_real_ip_from 172.64.0.0/13;
            set_real_ip_from 131.0.72.0/22;
            real_ip_header CF-Connecting-IP;
          '';
        };
      };
    };
  };
}
