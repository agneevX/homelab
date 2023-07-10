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

I run two Raspberry Pi 4Bs as servers currently.

### NAS/media server

<img src="https://user-images.githubusercontent.com/19761269/99898364-ea3dd680-2cc6-11eb-9216-89c2240ed0af.png" width="300">

`falcon`

- ⚡ Raspberry Pi 4B (8GB model)
  - Ubuntu Server 22.04 LTS
  - Overclocked to 2.0GHz
- 🔌 Powered USB 3.0 hub
  - TP-Link TL-UH700
- 📼 Primary storage
  - Sandisk Ultra microSD card (8GB, boot)
  - Crucial BX500 SSD (480GB, root FS)
- 📀 Secondary storage
  - Crucial BX500 SSD (480GB)
  - Seagate Barracuda 2.5" 1TB
  - Seagate Expansion 4TB
  - WD My Passport 1TB
  - Sony HD-B1 1TB
- 🌐 Gigabit ethernet
  - TP-Link TL-SG1008D
- 🔊 3.5mm out...
  - Fenda E200 Plus

Main server that runs the majority of my self-hosted apps, runs the media stack, functions as a NAS and audio server using the likes of `librespot`, `shairport-sync`, and `mpv`.

Runs in Docker containers:

[🔗 **Docker Compose**](./docker-compose/falcon.yml)

- 💡 [Home Assistant](https://github.com/agneevx/my-ha-setup)
- �📽 Plex Media Server
- 📺 Servarr media stack
- 🧲 qBittorrent

### DNS/proxy server

<img src="https://www.raspberrypi.com/app/uploads/2021/04/raspberrypi4-hero2-1536x1021.png" width="300">

`always-on`

- ⚡ Raspberry Pi 4 (4GB model)
  - Ubuntu Server 22.04 LTS
- 📼 32GB microSD card
- 🌐 Gigabit ethernet

[DNS/DHCP server](#dns), monitors network latency and speed using tools like Smokeping and Speedtest-tracker, handles the Traefik network proxy over Tailscale. Also runs Portainer, which is used to monitor Docker hosts across all machines, cloud or local.

Since this server runs on a SD card, `log2ram` is used to store system logs in memory to reduce writes to disk.

Runs in Docker containers:

[🔗 **Docker Compose**](./docker-compose/always-on.yml)

### Cloud VMs

- Oracle Cloud
- Google Cloud Platform (`e2-micro`)
- Digital Ocean Droplets

[🔗 **Docker Compose**](./docker-compose/oracle1.yml)

---

### DNS

[AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) blocks ads and trackers, manages DNS and DHCP in the local network.

For DNS resolution, I use Cloudflare Zero Trust over DoH3, which is similar to 1.1.1.1 but supports EDNS Client Subnet, which enables devices to connect to servers located closer to me and thus makes stuff load faster.

AdGuard has optimistic caching enabled which accelerates web page loading due to low latency lookups.

<!-- ![feb-2022-archive](https://user-images.githubusercontent.com/19761269/155761364-908e0759-6703-449c-8ca7-54a9c92b9478.png) -->

<!-- ![It's always DNS](https://user-images.githubusercontent.com/19761269/159464106-aac45518-26ef-4fe5-8bc3-865cb35e8868.png) -->

![Cloudflare Gateway DNS](https://user-images.githubusercontent.com/19761269/187674721-02be2231-9b3d-4eef-b3d7-08de09b8794e.png)

## Unified access

I use Tailscale to access devices and services. Cloud VMs have their storages securely mounted locally over NFS or FTP.

Some apps are hosted in cloud to balance system resources. I use Traefik to access them as if they're hosted locally, using the format `http://<app>.<machine>.nt`.

This requires Traefik and containers on all VMs, with Traefik routers created locally (for each VM) that proxy requests to remote Traefik instances.

## File management

Files are stored both in the cloud and locally.

### Media storage

mergerfs is used to pool together local drive mounts so they appear as a single mount that can be bind-mounted to Docker containers.
