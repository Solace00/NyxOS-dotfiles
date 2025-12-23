{ config, lib, pkgs, ... }:

let
  myPackages = import ./packages.nix { inherit pkgs; };
in
{
  # -------- imports --------
  imports =
    [
      ./hardware-configuration.nix
    ];

  # ----------- Bootloader -----------
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;

  # ------------- Services -------------
  services.getty.autologinUser = "frenny";
  services.printing.enable = true;

  services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    prime = {
      offload.enable = true;
      sync.enable = false;
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    nvidiaSettings = true;
    nvidiaPersistenced = true;
    powerManagement.enable = true;
  };

  specialisation = {
    gaming-time.configuration = {
      hardware.nvidia = {
        open = true;
        prime.sync.enable = lib.mkForce true;
        prime.offload.enable = lib.mkForce false;
        prime.offload.enableOffloadCmd = lib.mkForce false;
      };
    };
  };

  programs.gamemode.enable = true;


  # ------------- Basics -------------
  networking.hostName = "nyxos";
  time.timeZone = "Asia/Kolkata";
  networking.networkmanager.enable = true;

  # services.xserver.enable = true;

  services.udisks2.enable = true;

  # ------------- Updates & Maintenance -------------
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    flake = "~/.dotfiles/nixos#nyxos"; 
    #channel = "https://nixos.org/channels/nixos-25.11";
    dates = "weekly";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise = {
    automatic = true;
    dates = ["weekly"];
  };

  # ------------- Wayland & Hyprland -------------

  # services.displayManager.sddm.wayland.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

#  programs.niri = {
#    enable = true;
#  };


  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ------------- Audio -------------
  services.pipewire = {
     enable = true;
     pulse.enable = true;
  };


  # default Shell
  environment.shells = with pkgs; [ bash ];

  # ------------- Users & Programs -------------
  users.users.frenny = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
	    tree
     ];
  };

  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  services.upower.enable = true;
  powerManagement.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ------------- Packages -------------
  environment.systemPackages = myPackages;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
 
  # --------- Nix Settings ----------
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05"; # Did you read the comment?

}
