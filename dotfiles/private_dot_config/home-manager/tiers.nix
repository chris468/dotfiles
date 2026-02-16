{ lib, ... }:

{
  options.tiers = {
    aws.enable = lib.mkEnableOption "AWS tools";
    azure.enable = lib.mkEnableOption "Azure tools";
    container.enable = lib.mkEnableOption "Container tools";
    essential.enable = lib.mkEnableOption "Essential shell functionality";
    kubernetes.enable = lib.mkEnableOption "Kubernetes tools";
  };
}
