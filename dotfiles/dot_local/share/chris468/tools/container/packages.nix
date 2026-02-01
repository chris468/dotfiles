{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.tiers.container.enable {
    home.packages = with pkgs; # packages
      [ lazydocker ];
  };
}
