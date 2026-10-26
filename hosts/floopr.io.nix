# Host overlay: floopr.io VM (public subnet, docker host).
# Imports the shared base (../configuration.nix) and overrides only the
# per-host settings. Everything here intentionally deviates from the base
# defaults; see that file for the full shared config.
#
# Deploy with (adjust path to wherever the repo lives on the host):
#   sudo nixos-rebuild switch -I nixos-config=/etc/nixos/hosts/floopr.io.nix

{
  imports = [
    ../configuration.nix
  ];

  # Identity: FQDN is in.floopr.io (hostName + "." + domain).
  networking.hostName = "in";
  networking.domain = "floopr.io";

  # Static IP: public subnet, no DHCP. Address is excluded from the DHCP pool.
  networking.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "185.163.189.254";
      prefixLength = 24; # 24 = 255.255.255.0
    }
  ];
  networking.defaultGateway = {
    address = "185.163.189.1";
    interface = "eth0";
  };
  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  # SSH moved off port 22 to dodge casual port-22 scans. Port forwards on the
  # upstream firewall must point here; client: ssh -p 55522 lucian@<host>.
  services.openssh.ports = [ 55522 ];

  # Firewall: sshd, plus smtp/http/https for the services on this host.
  networking.firewall.allowedTCPPorts = [ 55522 25 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  # Lucian's admin account. isNormalUser + wheel group = sudo access via
  # the sudo wrapper (/run/wrappers/bin/sudo). Password is locked: login is
  # SSH-key only, sudo works without a password (wheelNeedsPassword = false
  # in the base) unless you remove that and set one with: passwd lucian
  users.users.lucian = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
}
