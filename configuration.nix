# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.graceful = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.configurationLimit = 5;

  networking.hostName = "docker-host";

  # DHCP on all interfaces.
  networking.useDHCP = true;

  time.timeZone = "Europe/Copenhagen";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  # Minimal management CLI tools.
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    net-tools
    psmisc
    tcpdump
    tmux
    vim
    wget
  ];

  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  # Docker runtime.
  virtualisation.docker.enable = true;

  system.copySystemConfiguration = true;

  system.stateVersion = "26.05";
}
