{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.tiers.essential.enable {
    home.packages = with pkgs; # Essential packages
      [
        carapace
        chezmoi
        nodejs
        oh-my-posh
      ];
  };
}
