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

  # Identify to the DHCP server by MAC address (RFC 2132 client-id) instead of
  # dhcpcd's default DUID. The DUID lives in /var/lib/dhcpcd/duid and is
  # generated fresh on every install, so a reinstalled VM looks like a brand
  # new client to the DHCP server even though the NIC's MAC is unchanged. That
  # breaks MAC reservations and makes servers that still hold a lease for the
  # old identity answer DHCPNAK ("requested address not available"). The MAC is
  # stable across reinstalls, so this keeps the machine's identity constant.
  networking.dhcpcd.extraConfig = ''
    clientid
  '';

  # --- Static IP alternative -------------------------------------------------
  # Preferred when the LAN has more than one DHCP server (an unsynced failover
  # pair will offer an address and then NAK the request for it, leaving the
  # host with no lease at all). Comment out networking.useDHCP above, set
  # it to false, and uncomment this block. Adjust the addresses to your LAN,
  # and make sure the chosen address is excluded from the DHCP pool.
  #
  # networking.useDHCP = false;
  # networking.interfaces.eth0.ipv4.addresses = [
  #   {
  #     address = "10.0.100.150";
  #     prefixLength = 24; # 24 = 255.255.255.0
  #   }
  # ];
  # networking.defaultGateway = {
  #   address = "10.0.100.1";
  #   interface = "eth0";
  # };
  # networking.nameservers = [
  #   "10.0.100.12"
  #   "10.0.100.13"
  # ];
  # ---------------------------------------------------------------------------

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
    fastfetch
    git
    hdparm
    htop
    lsb-release
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

  # --- SSH --------------------------------------------------------------------
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # --- SSH on a custom port (55522) -------------------------------------------
  # Uncomment to move sshd from port 22 to 55522. Only uncomment this section
  # right before you can test the new port — if sshd moves and the port is
  # unreachable, you lock yourself out of remote access.
  #
  # When active, also update:
  #   - any port forwards on the upstream firewall/router pointing here
  #   - your client command:  ssh -p 55522 user@host
  #
  # services.openssh.settings = {
  #   Port = 55522; # non-standard port to dodge casual port-22 scans
  # };
  #
  # The firewall is enabled by default (networking.firewall.enable = true),
  # and it must allow the port sshd actually listens on:
  # networking.firewall.allowedTCPPorts = [ 55522 ];
  #
  # Keep port 22 open during the switch so you can fall back if the new
  # port fails; remove it once 55522 is confirmed working:
  # networking.firewall.allowedTCPPorts = [ 22 55522 ];
  # -----------------------------------------------------------------------------

  #Enable the quemu guest agent (this can be removed if the virtualisation differs)
  services.qemuGuest.enable = true;

  # Docker runtime.
  virtualisation.docker.enable = true;

  # ----sudo config--------------------------------------------------------------
  # Lucian's admin account. isNormalUser + wheel group = sudo access via
  # the sudo wrapper (/run/wrappers/bin/sudo). Password is locked: login is
  # SSH-key only, sudo works without a password (wheelNeedsPassword = false
  # below) unless you remove that and set one with: passwd lucian
  # users.users.lucian = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ];
  # };
  # Allow sudo for wheel members without a password (account is key-only).
  # Remove if you prefer password-checked sudo (then set: passwd lucian).
  security.sudo.wheelNeedsPassword = false;
  # -----------------------------------------------------------------------------


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
