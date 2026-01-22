# Hardware configuration for Hetzner auction server
# This file will be generated during deployment with nixos-generate-config
# Placeholder for now - actual values depend on specific server hardware
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Boot
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    "kvm-amd"
  ];
  boot.extraModulePackages = [ ];

  # Enable hardware crypto acceleration if available
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Hetzner servers usually have good network cards
  networking.useDHCP = lib.mkDefault true;

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
