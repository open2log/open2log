{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.services.open2log-litestream = {
    enable = lib.mkEnableOption "Litestream replication for open2log";

    storageBoxHost = lib.mkOption {
      type = lib.types.str;
      description = "Hetzner storage box hostname";
      example = "u123456.your-storagebox.de";
    };

    storageBoxUser = lib.mkOption {
      type = lib.types.str;
      default = "u123456";
      description = "Hetzner storage box username";
    };

    sshKeyPath = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/open2log/ssh/id_ed25519";
      description = "Path to SSH key for storage box";
    };
  };

  config = lib.mkIf config.services.open2log-litestream.enable {
    # Install litestream
    environment.systemPackages = [ pkgs.litestream ];

    # Litestream configuration
    environment.etc."litestream.yml".text = ''
      dbs:
        - path: /var/lib/open2log/ducklake.sqlite
          replicas:
            # Replicate to Hetzner Storage Box via SFTP
            - type: sftp
              host: ${config.services.open2log-litestream.storageBoxHost}
              user: ${config.services.open2log-litestream.storageBoxUser}
              path: /backups/ducklake
              key-path: ${config.services.open2log-litestream.sshKeyPath}
              retention: 720h  # 30 days
              retention-check-interval: 1h
              sync-interval: 10s
              snapshot-interval: 1h
    '';

    # Systemd service for litestream
    systemd.services.litestream = {
      description = "Litestream SQLite Replication";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "open2log.service"
      ];

      serviceConfig = {
        Type = "simple";
        User = "open2log";
        Group = "open2log";
        ExecStart = "${pkgs.litestream}/bin/litestream replicate -config /etc/litestream.yml";
        Restart = "always";
        RestartSec = "5s";

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ReadWritePaths = [
          "/var/lib/open2log"
        ];
      };
    };
  };
}
