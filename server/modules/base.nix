{
  config,
  pkgs,
  lib,
  ...
}:

{
  # System basics
  system.stateVersion = "24.11";

  # Boot configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.devices = [ "nodev" ]; # EFI mode, no device needed

  # Networking
  networking.hostName = "memento-mori";
  networking.useDHCP = lib.mkDefault true;

  # Enable systemd-resolved for DNS
  services.resolved.enable = true;

  # Timezone - use UTC for servers
  time.timeZone = "UTC";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # Users
  users.users.root = {
    openssh.authorizedKeys.keys = [
      # Will be populated from terraform output or secrets
    ];
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
  ];

  # Enable automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Automatic updates
  system.autoUpgrade = {
    enable = true;
    flake = "github:onnimonni/open2log#memento-mori";
    dates = "04:00";
    randomizedDelaySec = "45min";
  };
}
