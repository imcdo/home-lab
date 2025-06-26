{ config, lib, pkgs, ... }:
{
  disko.devices.disk = {
    main = {
      device = "/dev/sda";
      layout = {
        "/boot" = {
            fsType = "vfat";
            size = "512M";
            label = "NIXBOOT";

        };
        "/" = {
            fsType = "ext4";
            size = "100%";
            label = "NIXROOT";
        };
      };
    };
  };
}
