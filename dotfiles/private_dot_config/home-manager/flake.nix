{
  description = "My Home Manager configuration";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tools = {
      url = "path:/home/chris/.local/share/chris468/tools";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, tools, ... }:
    let
      # inherit (nixpkgs) lib;
      chezmoiConfig = import ./chezmoi-config.nix;
      inherit (chezmoiConfig) system;
      inherit (chezmoiConfig) username;
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations."${username}" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix

            # tool profiles
            ./tiers.nix
            "${tools}/essential/packages.nix"

            # tool selections. (must be last)
            ./tools.nix
          ];
          extraSpecialArgs = { inherit chezmoiConfig; };
        };
    };
}
# modules = [
#   ./home/tiers.nix
#
#   ./home/packages/base.nix
#   ./home/packages/extended.nix
#   ./home/packages/dev.nix
#
#   ./home/profiles/devbox.nix
# ];
