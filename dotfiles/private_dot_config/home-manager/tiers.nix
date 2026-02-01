{ lib, ... }:

{
  options.tiers = {
    essential.enable = lib.mkEnableOption "Minimal shell functionality";
  };
}
