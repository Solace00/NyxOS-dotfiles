{ config, pkgs, ... }:

{
  home.username = "frenny";
  home.homeDirectory = "/home/frenny";
  home.stateVersion = "25.11";

  # let home-manager manage itself
  programs.home-manager.enable = true;
}
