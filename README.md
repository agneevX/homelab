# My Server Setup

My server setup at home

- [My Server Setup](#my-server-setup)
  - [Hardware](#hardware)
    - [Media server](#media-server)
    - [Server 2](#server-2)
  - [Software](#software)
  - [File management](#file-management)
    - [Cloud storage](#cloud-storage)
    - [Local storage](#local-storage)
  - [Media management](#media-management)
  - [VS Code](#vs-code)
    - [Plugins](#plugins)
    - [Theme/icon packs](#themeicon-packs)
  - [Backups and updates](#backups-and-updates)
  - [Notes](#notes)

## Hardware

I run two Raspberry Pi 4 as servers at home presently.

<img src="https://user-images.githubusercontent.com/19761269/99898364-ea3dd680-2cc6-11eb-9216-89c2240ed0af.png" width="300">

### Media server

`server`

- Raspberry Pi 4 (8GB model)
  - Raspberry Pi OS Lite - Debian Buster
  - Overclocked to 2.1GHz
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
- 🌐 Ethernet (Gigabit)
  - TP-Link TL-SG1008D
- 🔊 3.5mm out...
  - Fenda E200 Plus

<img src="https://www.raspberrypi.org/homepage-9df4b/static/raspberry-pi-os-32bit-3697e93ad6828805810ffa5f4651423c.jpg" width="300">

### Server 2

`always-on`

- Raspberry Pi 4 (4GB model)
  - Raspberry Pi OS Lite - Debian Buster
- 📼 32GB microSD card
- 🌐 Ethernet (Gigabit)

`always-on` functions primarily as a network blocker and runs limited software such as Homebridge.

## Software

- 📽 Plex Media Server
  - Tautulli
  - `plex-autoscan`
- ☁️ rclone
- 🗃 mergerFS
- 👨‍💻 VS Code (`code-server`)
- ⏳ ..arrs
  - Sonarr, Radarr,
  - Bazarr, Jackett and Tdarr
- 🧲 qBittorrent
  - `qb-web` front-end
- ⏬ aria2
  - `ariaNg` front-end
  - `tele-aria2`
- 🌎 AdGuard Home

Smart Home 🏠

- 💡 [Home Assistant](https://github.com/agneevx/my-ha-setup)
- 📱 Homebridge

![bashtop](https://user-images.githubusercontent.com/19761269/92084333-dd56c880-ede4-11ea-9c97-f22d6bf39744.jpg "Bashtop running inside Cockpit, powered by NGINX, with help from AdGuard Home")

System Monitoring 👀

- ✈️ Cockpit
- 🛠 Webmin
- 📈 Netdata
- 💻 `webssh`
- `vnstat`, `bashtop`, `iftop`, `iotop` and `iostat`

Others 💬

- 🌐 Nginx
- 📂 File Browser
- 🗂 Samba (SMB)
- 🎶 `shairport-sync`
- 🎶 `raspotify`
- 🏎 Librespeed

Most third-party software are located at `/opt`.

---

## File management

Files are stored both locally and in the cloud.

### Cloud storage

rclone is used for cloud storage to access files from the cloud and for backups. Most of my files are stored there.

At system startup, a systemd service file using rclone mounts the cloud drive to `/drive` and caches the entire file structure in memory, while mergerFS creates a mount that combines a local folder and the rclone mount so that any newly added files are stored locally.

Everyday at 12PM, a script moves this local content to the cloud.

The mount options used ensure the accessed data is buffered in-memory before being sent to the client, which results in better responsiveness and lower latency.

### Local storage

Also at startup, mergerFS combines all external drives and creates a single FUSE mount point, `/knox` using a systemd mount file.

All disks are formatted in `ext4` (with no reserved space) and mounted inside `/mnt/pool`.

---

## Media management

I use Plex to play content on my devices from my server locally.

Both `/knox` and `/drive` are added to Plex as I store content in both places.
I've changed a few settings in Plex to reduce data use because the files are stored remotely.

![plex](https://user-images.githubusercontent.com/19761269/99898814-68e84300-2cca-11eb-895b-e5b800eb9440.png "Plex Library Settings")

<b>..arrs</b> ⤵️

The process of grabbing new content for playback in Plex is automated via software aka -arrs.

Radarr is used for movies and Sonarr for TV Shows while Bazarr gathers subtitles.
Currently, I'm running beta versions of Radarr and Sonarr.
I use the qBittorrent torrent client.

For Radarr auto-import, I use Trakt auto import lists.

For Sonarr, these are my release profiles:

![sonarr_release_profiles](https://user-images.githubusercontent.com/19761269/99898367-ee69f400-2cc6-11eb-8c19-7849a0ab67d6.png "Sonarr Release Profiles")

---

## VS Code

<img width="1136" alt="image" src="https://user-images.githubusercontent.com/19761269/99899106-ac43b100-2ccc-11eb-9f22-d6eaf54e7fbc.png">

I use Visual Studio Code as my sole code editor these days.

These are some of my most-used extensions:

### Plugins

- Remote - SSH
- Prettier
- GitLens
- Bracket Pair Colorizer 2
- Auto Rename Tag
- indent-rainbow
- Markdown All in One
- Day Night Theme Switcher

### Theme/icon packs

- GitHub Light
- GitHub Dark
- Synthwave' 84
- Material Icon Theme

## Backups and updates

Every day at 9PM, a couple of scripts run that backup certain important files/databases to my cloud drive using rclone.

These tasks are done by cron jobs and I use Healthchecks.io for monitoring. I receive notifications from the Healthchecks Telegram bot if jobs fail to complete.

All backup scripts are located inside `./scripts/backup`.

---

## Notes

- Some applications have a delayed startup (cron):

```bash
@reboot sleep 40 && sudo systemctl start drive radarr sonarr hass
```