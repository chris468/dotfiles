{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.tiers.essential.enable {
    home.packages = with pkgs; # packages
      [
        bat
        btop
        carapace
        chezmoi
        delta
        eza
        fd
        fzf
        github-cli
        jq
        lazygit
        lsd
        neovim
        nodejs
        oh-my-posh
        python3
        ripgrep
        step-cli
        wezterm
        yq
        zoxide
      ];
  };
}
