{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.tiers.kubernetes.enable {
    home.packages = with pkgs; # packages
      [
        helm
        k9s
        kubectl
      ];
  };
}
