{ config, lib, pkgs, ... }:

let
  myPackages = import ./packages/default.nix { inherit pkgs; };
in
{
  imports = [ ./hardware-configuration.nix ];

  # ----------- Bootloader -----------
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # ----------- Kernel -----------
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # ------------- GPU ---------------
  services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
    powerManagement.enable = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      sync.enable = false;
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  specialisation.gaming.configuration = {
    hardware.nvidia.prime = {
      sync.enable = lib.mkForce true;
      offload.enable = lib.mkForce false;
      offload.enableOffloadCmd = lib.mkForce false;
    };
  };

  # ------------- ZRAM -------------
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # ------------- Basics -------------
  networking = {
    hostName = "nyxos";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  services.udisks2.enable = true;
  services.printing.enable = true;
  services.upower.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ------------- Power -------------
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # ------------- Fonts -------------
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # ------------- Wayland & Hyprland -------------
  services.getty.autologinUser = "frenny";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  programs.dconf.enable = true;

  # ------------- Audio -------------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire."99-lowlatency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 512;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 512;
      };
    };
  };

  # ------------- Gaming -------------
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  environment.sessionVariables = {
    DXVK_STATE_CACHE = "1";
    DXVK_ASYNC = "1";
  };

  # ------------- System Programs -------------
  programs.git.enable = true;
  programs.firefox.enable = true;
  programs.zsh.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;

  programs.ssh.startAgent = true;

  # ------------- Users -------------
  users.users.frenny = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
      "video"
      "audio"
      "gamemode"
    ];
    packages = with pkgs; [ tree ];
  };

  # ------------- Packages -------------
  environment.systemPackages = myPackages;

  # ------------- Nix -------------
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };                          # <-- settings closes here

    gc = {                      # <-- gc is under nix, not nix.settings
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    flake = "~/.dotfiles/nixos#nyxos";
    dates = "weekly";
  };

  system.stateVersion = "25.11";
}
