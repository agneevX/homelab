<!-- markdownlint-disable MD033 -->
# Homelab Setup

My servers setup at home

- [Homelab Setup](#homelab-setup)
  - [Hardware](#hardware)
    - [NAS/media server](#nasmedia-server)
    - [DNS server](#dns-server)
  - [File management](#file-management)
    - [Cloud storage](#cloud-storage)
    - [Local storage](#local-storage)
  - [Media management](#media-management)

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

Runs (mostly in Docker):

[🔗 Docker Compose](./compose/falcon.yml)

- 💡 [Home Assistant](https://github.com/agneevx/my-ha-setup)
- 📽 Plex Media Server
- 📺 Sonarr/Radarr/Prowlarr
- 🙋‍♂️ Overseerr
- 🧲 qBittorrent

More in [`docker_compose.yml`](./docker-compose.yml).

---

### DNS server

<img src="https://www.raspberrypi.org/homepage-9df4b/static/raspberry-pi-os-32bit-3697e93ad6828805810ffa5f4651423c.jpg" width="300">

`always-on`

- ⚡ Raspberry Pi 4 (4GB model)
  - Ubuntu Server 20.04 LTS
- 📼 32GB microSD card
- 🌐 Gigabit ethernet

Runs (mostly in Docker):

[🔗 Docker Compose](./compose/always-on.yml)

- 🌎 AdGuard Home
- 📱 Homebridge
- 🌎 Homer

## File management

Files are stored both in the cloud and locally.

### Cloud storage

[rclone](https://github.com/rclone/rclone) and [plexdrive](https://github.com/plexdrive/plexdrive) is used to communicate with various cloud storages.

During system startup, two systemd files mount rclone remotes to [`/mnt/rc-drive`](./systemd/rc-drive.service) and [`/mnt/rc-crypt`](./systemd/rc-crypt.service) and caches the entire file structure in memory.

Another systemd file uses mergerFS to create a mount at [`/mnt/mfs-drive`](./systemd/mfs-drive.service) that combines the above two mount points with another local folder, that way all new files are created locally.

Plexdrive mounts are mounted the same way.

```bash
# SSD cache
/opt/.drive ->-|
/mnt           |
../*drive -->--|
../*crypt -->--|
/drive  <------|
```

Everyday at 1PM, a cron job runs a script that moves the local content to the cloud, depending upon their age.

### Local storage

Also at startup, mergerFS combines all external drives and creates a single mount point at `/mnt/mfs-knox` using a systemd mount file.

All disks are formatted in `ext4` (with no reserved space) and mounted inside `/mnt/pool` using fstab entries.

---

## Media management

I use Plex to play content on my devices from my server.

For cloud Plex playback only, I use [Plexdrive](./systemd/mfs-plexdrive.service) since its faster, otherwise all other apps use the rclone-mergerFS mount.

Both `/knox` and `/drive` (plexdrive) are added to Plex as I store content in both places.

I've changed a few settings in Plex to optimize for cloud files:

![plex](https://user-images.githubusercontent.com/19761269/99898814-68e84300-2cca-11eb-895b-e5b800eb9440.png "Plex library configuration")
