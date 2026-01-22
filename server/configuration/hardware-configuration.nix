# Hardware configuration for Hetzner auction server (bare metal)
# srvos.nixosModules.hardware-hetzner-online-amd provides most hardware settings
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Additional kernel modules for NVMe and storage
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  # ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  # ZFS requires a unique hostId (8 hex chars)
  # Generated with: head -c4 /dev/urandom | od -A none -t x4 | tr -d ' '
  networking.hostId = "a8c9e1f2";

  # Enable firmware updates
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
