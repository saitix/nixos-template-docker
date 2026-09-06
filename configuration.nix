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

  networking.hostName = "docker-host"; # TODO: set real hostname  
  networking.domain = "example.com"; #TODO: set the real domain

  # Disable predictable interface names (enp1s0, ens33, ...) so NICs keep
  # classic kernel names: eth0, eth1, ... (adds net.ifnames=0 to kernel params).
  networking.usePredictableInterfaceNames = false;
  
  # Internal-network-only server; external access arrives via port forwarding
  # on the firewall. IP is assigned by DHCP (optionally reserved for this
  # VM's MAC address on the DHCP server).
  # Interface names aren't hardcoded so the config works on any NIC:
  # with scripted networking, useDHCP enables it on all interfaces.
  networking.useDHCP = true;
  # If you later want DHCP on a specific interface only, uncomment and set:
  # networking.useDHCP = false;
  # networking.interfaces.eth0.useDHCP = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  #nix Garbage collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  # Minimal management CLI tools.
  environment.systemPackages = with pkgs; [
    curl
    docker
    elinks
    git
    hdparm
    htop
    mc
    net-tools
    nmon
    psmisc
    pydf
    tcpdump
    tmux
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  #Enable the Openssh service
  services.openssh.enable = true;
  #Enable the quemu guest agent (this can be removed if the virtualisation differs)
  services.qemuGuest.enable = true;

  # Docker runtime.
  virtualisation.docker.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

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

  system.stateVersion = "26.05";
}
