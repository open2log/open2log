{
  description = "NixOS configuration for open2log server";

  inputs = {
    # Use srvos for server defaults and Hetzner hardware support
    srvos.url = "github:nix-community/srvos";
    nixpkgs.follows = "srvos/nixpkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fetch SSH keys from GitHub
    onnimonni-ssh-keys = {
      url = "https://github.com/onnimonni.keys";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      srvos,
      disko,
      sops-nix,
      ...
    }@inputs:
    {
      nixosConfigurations.memento-mori = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          # nixos-anywhere terraform module will inject values here
          terraformArgs = { };
        };
        modules = [
          # Server defaults from srvos
          srvos.nixosModules.server
          srvos.nixosModules.hardware-hetzner-online-amd
          # Disko for disk management
          disko.nixosModules.disko
          # SOPS for secrets
          sops-nix.nixosModules.sops
          # Hardware config
          ./hardware-configuration.nix
          # ZFS disk layout for 3x3.84TB NVMe
          ../modules/disko-zfs.nix
          # Server modules
          ../modules/base.nix
          ../modules/firewall.nix
          ../modules/phoenix.nix
          ../modules/gluetun.nix
          ../modules/litestream.nix
          ../modules/crawler.nix
          # Server-specific config
          ./memento-mori.nix
        ];
      };
    };
}
