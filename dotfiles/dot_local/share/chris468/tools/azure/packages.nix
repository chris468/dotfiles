{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.tiers.azure.enable {
    home.packages = with pkgs; # packages
      [
        azure-cli
        azure-kubelogin
      ];
  };
}
