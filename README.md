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
  - Ubuntu Server 20.04 LTS
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

Main server that runs most of my self-hosted apps and also functions as a NAS.

Runs (mostly in Docker):

[🔗 **Docker Compose**](./docker-compose/falcon.yml)

- 💡 [Home Assistant](https://github.com/agneevx/my-ha-setup)
- 📶 Grafana/Promethus
- 📽 Plex Media Server
- 📺 Sonarr/Radarr
- 🧲 qBittorrent

---

### DNS/proxy server

<img src="https://www.raspberrypi.com/app/uploads/2021/04/raspberrypi4-hero2-1536x1021.png" width="300">

`always-on`

- ⚡ Raspberry Pi 4 (4GB model)
  - Ubuntu Server 20.04 LTS
- 📼 32GB microSD card
- 🌐 Gigabit ethernet

Functions as the main DNS and DHCP server, while also blocking ads in the network, using AdGuard Home.

For DNS, I use Google DNS, which supports EDNS Client Subnet, which provides faster speeds and a decreased latency for certain CDNs like Akamai or Cloudfront.

Due to the usage of ECS by default, DNS queries are quite slow, so for DNS caching, I use the versatile Unbound.

Since Unbound is limited to DNS over TLS, and I've had issues with DNSSEC failures in the past, I use blocky as upstream, which connects to Google's servers over DNS over HTTPS.

This server also handles the Traefik network proxy over Tailscale. More on that below.

Since this server runs on a SD card, `log2ram` is used to store logs in-memory to reduce writes.

Runs (mostly in Docker):

[🔗 **Docker Compose**](./docker-compose/always-on.yml)

### Cloud VMs

- Oracle Cloud (A1 Compute)
- Google Cloud Platform (`e2-micro`)
- Digital Ocean Droplets

[🔗 **Docker Compose**](./docker-compose/oracle1.yml)

## Unified access

I use Tailscale to access all devices and services. All cloud VMs have their storages mounted locally using NFS, securely.

Some self-hosted apps are hosted in cloud to minimize latency, I use Traefik to access them as if they're hosted locally, using the syntax `<service_name>.<machine_name>.nt`.

This does require Traefik and *Dockerized* apps on all VMs, with Traefik routers created locally (for each VM) that proxy requests to them.
VMs not running Docker (due to resource constraints) must be added manually or until I can find a better solution.

This means I'm able to load Jackett, hosted in the `gcp1` VM using the URL `jackett.gcp1.nt`.

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