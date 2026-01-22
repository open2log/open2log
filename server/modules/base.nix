{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Networking
  networking.useDHCP = lib.mkDefault true;

  # Enable systemd-resolved for DNS
  services.resolved.enable = true;

  # Timezone - use UTC for servers
  time.timeZone = "UTC";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Fish shell
  programs.fish.enable = true;

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # Essential packages
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    tmux
    curl
    wget
    duckdb
    fish
  ];

  # Enable automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Enable flakes and remote builds
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Allow root to be used for remote nix builds
    trusted-users = [ "root" ];
  };

  # Automatic updates
  system.autoUpgrade = {
    enable = true;
    flake = "github:open2log/open2log#memento-mori";
    dates = "04:00";
    randomizedDelaySec = "45min";
  };
}
