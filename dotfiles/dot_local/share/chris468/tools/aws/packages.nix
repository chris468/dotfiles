{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.tiers.aws.enable {
    home.packages = with pkgs; # packages
      [
        aws-cli-v2
        eksctl
      ];
  };
}
