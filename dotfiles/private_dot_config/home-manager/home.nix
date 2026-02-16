{ chezmoiConfig, ... }:

{
  config = {
    home = {
      inherit (chezmoiConfig) username;
      inherit (chezmoiConfig) homeDirectory;
      stateVersion = "25.05"; # Do not change unless docs consulted
    };

    programs.home-manager.enable = true;
  };
}
