<!-- markdownlint-disable MD033 -->
# Homelab Setup

My servers setup at home

- [Homelab Setup](#homelab-setup)
  - [Hardware](#hardware)
    - [NAS/media server](#nasmedia-server)
    - [DNS/proxy server](#dnsproxy-server)
    - [Cloud VMs](#cloud-vms)
  - [Unified access](#unified-access)
  - [File management](#file-management)
    - [Cloud storage](#cloud-storage)
    - [Local storage](#local-storage)

## Hardware

I run two Raspberry Pi 4s' as servers currently.

### NAS/media server

<img src="https://user-images.githubusercontent.com/19761269/99898364-ea3dd680-2cc6-11eb-9216-89c2240ed0af.png" width="300">

`falcon`

- ⚡ Raspberry Pi 4 (8GB model)
  - Ubuntu Server 22.04 LTS
  - Overclocked to 2.0GHz
- 🔌 Powered USB 3.0 hub
  - TP-Link TL-UH700
- 📼 Primary storage
  - Sandisk Ultra microSD card (8GB, boot)
  - Crucial BX500 SSD (480GB, root)
- 📀 Secondary storage
  - Seagate Expansion 4TB
  - Seagate Barracuda 2.5" 1TB
  - WD My Passport 1TB
  - Sony HD-B1 1TB
- 🌐 Gigabit ethernet
  - TP-Link TL-SG1008D
- 🔊 3.5mm out...
  - Fenda E200 Plus

Main server that runs the majority of my self-hosted apps, functions as a NAS and audio server using `librespot`, `shairport-sync`, and `mpv`.

Runs (mostly in Docker):

[🔗 **Docker Compose**](./docker-compose/falcon.yml)

- 💡 [Home Assistant](https://github.com/agneevx/my-ha-setup)
- � Grafana/Prometheus
- �📽 Plex Media Server
- 📺 Sonarr/Radarr
- 🧲 qBittorrent

### DNS/proxy server

<img src="https://www.raspberrypi.com/app/uploads/2021/04/raspberrypi4-hero2-1536x1021.png" width="300">

`always-on`

- ⚡ Raspberry Pi 4 (4GB model)
  - Ubuntu Server 20.04 LTS
- 📼 32GB microSD card
- 🌐 Gigabit ethernet

[DNS/DHCP server](#DNS), also handles the Traefik network proxy over Tailscale, more on that below.

Since this server runs on a SD card, `log2ram` is used to store certain logs in-memory to reduce writes.

Runs (mostly in Docker):

[🔗 **Docker Compose**](./docker-compose/always-on.yml)

### Cloud VMs

- Oracle Cloud (A1 Compute)
- Google Cloud Platform (`e2-micro`)
- Digital Ocean Droplets

[🔗 **Docker Compose**](./docker-compose/oracle1.yml)

---

### DNS

[AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) manages DNS and DHCP, as well as acts as the content-blocker in the network.

I use Cloudflare Gateway DNS over DNS-over-HTTPS, which is similar to 1.1.1.1 but supports EDNS Client Subnet in addition to it being a managed DNS service.

<!-- ![feb-2022-archive](https://user-images.githubusercontent.com/19761269/155761364-908e0759-6703-449c-8ca7-54a9c92b9478.png) -->

<!-- ![It's always DNS](https://user-images.githubusercontent.com/19761269/159464106-aac45518-26ef-4fe5-8bc3-865cb35e8868.png) -->

![Cloudflare Gateway DNS](https://user-images.githubusercontent.com/19761269/187674721-02be2231-9b3d-4eef-b3d7-08de09b8794e.png)

## Unified access

I use Tailscale to access all devices and services. All cloud VMs have their storages mounted locally using NFS, securely.

Some apps are hosted in cloud to balance system resources. I use Traefik to access them as if they're hosted locally, using the format `http://<app>.<machine>.nt`.

This requires Traefik and containers on all VMs, with Traefik routers created locally (for each VM) that proxy requests to remote Traefik instances.

## File management

Files are stored both in the cloud and locally.

### Cloud storage

[rclone](https://github.com/rclone/rclone) is used to communicate with various cloud storages.

During system startup, two systemd files mount rclone remotes to [`/mnt/rc-drive`](./systemd/rc-drive.service) and [`/mnt/rc-crypt`](./systemd/rc-crypt.service) and caches the entire file structure in memory.

Another systemd file uses mergerFS to create a mount at [`/mnt/mfs-drive`](./systemd/mfs-drive.service) that combines the above two mount points with another local folder, that way all new files are created locally.

```sh
# SSD cache
/home/../drive-local ->-|
/mnt/rc-drive  ---->----|
/mnt/rc-crypt  ---->----|
# NFS mounts over Tailscale
/mnt/oc*-drive ---->----|
                        |
/mnt/mfs-drive  <-------|
```

At 6AM everyday, a cron job runs a script that moves local content to the cloud.

### Local storage

Also at startup, mergerFS combines all external drives and creates a single mount point at `/mnt/mfs-knox` using a systemd mount file.

All disks are formatted in `ext4` (with no reserved space) and mounted inside `/mnt/pool` using fstab entries.
