# Disk configuration for Hetzner auction server
# This will be automatically configured based on the server's disk layout
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Device will be determined during deployment
        # Common options: /dev/sda, /dev/nvme0n1
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
