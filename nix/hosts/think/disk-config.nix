{ config, lib, pkgs, ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
                label = "NIXBOOT";
              };
            };
            swap = {
              size = "2G";
              content = {
                type = "swap";
                label = "NIXSWAP";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [
                  "defaults"
                ];
                label = "NIXROOT";
              };
            };
          };
        };
      };
    };
  };
}
