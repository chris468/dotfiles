{
  description = "My Home Manager configuration";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      # inherit (nixpkgs) lib;
      chezmoiConfig = import ./chezmoi-config.nix;
      inherit (chezmoiConfig) system;
      inherit (chezmoiConfig) username;
      pkgsUnstable = import nixpkgs-unstable { inherit system; };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            oh-my-posh = pkgsUnstable.oh-my-posh;
          })
        ];
      };
    in {
      homeConfigurations."${username}" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix

            # tool profiles
            ./tiers.nix
            ./tools/essentials.nix
            ./tools/container.nix
            ./tools/kubernetes.nix
            ./tools/aws.nix
            ./tools/azure.nix

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
