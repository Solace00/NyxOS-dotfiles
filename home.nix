{ config, pkgs, ... }:

{
  home.username = "frenny";
  home.homeDirectory = "/home/frenny";
  home.stateVersion = "25.05";
  programs.git.enable = true;
  programs.bash = {
    enable = true;
    shellAliases = {
      nyx = "echo could've went with Twilight";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nyxos";
    };
    profileExtra = ''
      exec hyprland
    '';
  };
}