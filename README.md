<!-- markdownlint-disable MD033 -->
# Homelab Setup

My servers setup at home

- [Homelab Setup](#homelab-setup)
  - [Hardware](#hardware)
    - [NAS Server](#nas-server)
    - [DNS Server](#dns-server)
  - [File management](#file-management)
    - [mergerFS and rclone](#mergerfs-and-rclone)
    - [Local storage](#local-storage)
  - [Media management](#media-management)
  - [Notes](#notes)

## Hardware

I run two Raspberry Pi 4s' as servers currently.

### NAS Server

<img src="https://user-images.githubusercontent.com/19761269/99898364-ea3dd680-2cc6-11eb-9216-89c2240ed0af.png" width="300">

`falcon`

- Raspberry Pi 4 (8GB model)
  - Ubuntu Server 20.04
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
- 🌐 Gigabit Ethernet
  - TP-Link TL-SG1008D
- 🔊 3.5mm out...
  - Fenda E200 Plus

Runs:

- 💡 [Home Assistant](https://github.com/agneevx/my-ha-setup)
- 📽 Plex Media Server
- ☁️ rclone
- 🗃 mergerFS
- 📺 Sonarr
- 🎬 Radarr
- 🧲 qBittorrent w/ [`qb-web`](https://github.com/CzBiX/qb-web)/[`vuetorrent`](https://github.com/WDaan/VueTorrent)
- ⏬ aria2 w/ [`ariaNg`](https://github.com/mayswind/AriaNg)
- 📂 File Browser
- 📊 Tautulli
- `plex-autoscan`

---

### DNS Server

<img src="https://www.raspberrypi.org/homepage-9df4b/static/raspberry-pi-os-32bit-3697e93ad6828805810ffa5f4651423c.jpg" width="300">

`always-on`

- Raspberry Pi 4 (4GB model)
  - Ubuntu Server 20.04
- 📼 32GB microSD card
- 🌐 Gigabit Ethernet

Runs:

- 🌎 AdGuard Home
- 🌍 Unbound
- 📱 Homebridge
- 🧩 Jackett
- ✈️ Cockpit
- 🏎 Librespeed

## File management

Files are stored both in the cloud and locally.

### mergerFS and rclone

rclone is the tool that's used to communicate with various cloud storages.

During system startup, two systemd files mount cloud drives to [`/mnt/drive`](./systemd/drive.service) and [`/mnt/crypt`](./systemd/crypt.service). This process also caches the entire file structure in-memory.

Another systemd file calls mergerFS to create a mount at [`/drive`](./systemd/drive.mount) that combines the above two mount points and another local folder at `/opt/.drive`.

That way all new files are created locally.

```bash
/opt # SSD cache
.../.drive  ---|
/mnt           |
.../drive  ----|
.../crypt  ----|
/drive    <----|
```

Everyday at 11AM, a cron job runs a script that moves the local content to the cloud, depending upon their age.

### Local storage

Also at startup, mergerFS combines all external drives and creates a single mount point at `/knox` using a systemd mount file.

All disks are formatted in `ext4` (with no reserved space) and mounted inside `/mnt/pool` using fstab entries.

---

## Media management

I use Plex to play content on my devices from my server.

Both `/knox` and `/drive` are added to Plex as I store content in both places.

I've changed a few settings in Plex to optimize for cloud files:

![plex](https://user-images.githubusercontent.com/19761269/99898814-68e84300-2cca-11eb-895b-e5b800eb9440.png "Plex Library Settings")

<b>..arrs</b> ⤵️

The process of grabbing new content for playback in Plex is automated via software aka _-arrs_.

Radarr is used for movies and Sonarr for TV Shows with qBittorrent client.

For Radarr auto-import, I use IMDb and Trakt auto import lists.

For Sonarr, these are my release profiles:

![sonarr_release_profiles](https://user-images.githubusercontent.com/19761269/99898367-ee69f400-2cc6-11eb-8c19-7849a0ab67d6.png "Sonarr Release Profiles")

---

## Notes

- Some applications have a delayed startup (cron):

```bash
@reboot sleep 40 && sudo systemctl start drive crypt
@reboot sleep 45 && sudo systemctl start qbt radarr sonarr
@reboot sleep 60 && sudo systemctl start hass
```
