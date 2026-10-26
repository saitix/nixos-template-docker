# NixOS Docker Template

A NixOS configuration template for a basic VM/server setup with Docker and a
minimal set of management command-line tools.

## Files

| File | Purpose |
| --- | --- |
| `configuration.nix` | Shared base config (boot, DHCP networking, locale/timezone, Nix GC, Docker, OpenSSH, QEMU guest, management CLI tools). Host-specific values it sets are `mkDefault` fallbacks, overridable by a host overlay. |
| `hosts/<name>.nix` | Per-host overlay: imports the base and sets hostname, domain, networking (DHCP or static), SSH port, firewall, users. One file per host. |
| `hardware-configuration.nix` | QEMU guest profile + mounts by filesystem LABEL (`root`, `BOOT`) |
| `partition-disk.sh` | Wipes a target disk, creates the UEFI layout, formats filesystems, and rewrites `hardware-configuration.nix` using LABEL-based mounts |

## Included services and tooling

- Docker daemon (`virtualisation.docker.enable = true`)
- OpenSSH
- QEMU guest agent
- CLI utilities: `curl`, `docker`, `elinks`, `git`, `hdparm`, `htop`, `mc`, `net-tools`, `nmon`, `psmisc`, `pydf`, `tcpdump`, `tmux`, `vim`, `wget`

## Default configuration highlights

- Hostname/domain placeholders: `docker-host` / `example.com` (mkDefault —
  every real host overrides them in its `hosts/<name>.nix` overlay)
- DHCP enabled on all interfaces (`networking.useDHCP = true`, mkDefault),
  identifying by MAC address rather than dhcpcd's per-install DUID so MAC
  reservations survive a reinstall; a host overlay can switch to static
- Time zone: `Europe/Copenhagen`
- Locale: `en_US.UTF-8`
- Nix garbage collection: weekly, deleting generations older than 60 days

## Host overlays

Each host gets one file under `hosts/` that imports the shared base and sets
only what differs: hostname, domain, static vs DHCP networking, SSH port,
firewall rules, user accounts. See `hosts/floopr.io.nix` for a full example.

## Deploying

From scratch on a new VM (boot the NixOS minimal ISO, clone this repo):

```sh
git clone <this-repo> /tmp/nixos-template && cd /tmp/nixos-template
sudo ./partition-disk.sh /dev/vda --mount
sudo cp -r . /mnt/etc/nixos
sudo nixos-install --root /mnt -I nixos-config=/mnt/etc/nixos/hosts/<name>.nix
```

On an already-installed system (repo checked out at /etc/nixos):

```sh
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/hosts/<name>.nix
```

To make `<name>` the permanent default on a host, point
`/etc/nixos/configuration.nix` at the overlay instead:

```nix
{ imports = [ ./hosts/<name>.nix ]; }
```
