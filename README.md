# NixOS Docker Template

A NixOS configuration template for a basic VM/server setup with Docker and a
minimal set of management command-line tools.

This template intentionally excludes WHMCS-specific components:

- webserver config
- ionCube
- PHP
- Percona/MySQL

## Files

| File | Purpose |
| --- | --- |
| `configuration.nix` | Base system config (boot, DHCP networking, Docker, OpenSSH, minimal CLI tools) |
| `hardware-configuration.nix` | QEMU guest profile + mounts by filesystem LABEL (`root`, `BOOT`) |
| `partition-disk.sh` | Wipes a target disk, creates the UEFI layout, formats filesystems, and rewrites `hardware-configuration.nix` using LABEL-based mounts |

## Included services and tooling

- Docker daemon (`virtualisation.docker.enable = true`)
- OpenSSH
- QEMU guest agent
- CLI utilities: `curl`, `git`, `htop`, `net-tools`, `psmisc`, `tcpdump`, `tmux`, `vim`, `wget`

## Deploying

From scratch on a new VM (boot the NixOS minimal ISO, clone this repo):

```sh
git clone <this-repo> /tmp/nixos-template && cd /tmp/nixos-template
sudo ./partition-disk.sh /dev/vda --mount
sudo cp -r . /mnt/etc/nixos
sudo nixos-install --root /mnt
```

On an already-installed system:

```sh
nixos-rebuild switch
```
