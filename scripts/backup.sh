#!/bin/bash
set -e
if [[ -z "$1" ]]; then echo 'Not found'; exit 1; else service="$1"; fi
RCLONE_OPTIONS=( --retries 60 --retries-sleep 30s)

if [[ $service == 'home-assistant' ]]; then
  HC_URL=https://hc-ping.com/
  curl -fsS --retry 5 $HC_URL/start
  o=$(sudo rclone sync /home/homeassistant mydrive:Backup/home-assistant "${RCLONE_OPTIONS[@]}" --transfers=16 --exclude-from=/home/homeassistant/.ha_excludes --config="$RCLONE_CONFIG" 2>&1)
  sudo chown -R agneev:agneev /home/agneev/.config/rclone
  curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?; fi
if [[ $service == 'plex_db' ]]; then
  HC_URL=https://hc-ping.com/
  curl -fsS --retry 5 $HC_URL/start
  o=$(rclone copy "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db" mydrive:Backup/plex 2>&1)
  curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?; fi
if [[ $service == 'radarr' ]]; then
  HC_URL=https://hc-ping.com/
  curl -fsS --retry 5 $HC_URL/start
  o=$(rclone copy /home/agneev/.config/Radarr mydrive:Backup/radarr --include={radarr.db,config.xml} "${RCLONE_OPTIONS[@]}" 2>&1)
  curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?; fi
if [[ $service == 'sonarr' ]]; then
  HC_URL=https://hc-ping.com/
  curl -fsS --retry 5 $HC_URL/start
  o=$(rclone copy /var/lib/sonarr mydrive:Backup/sonarr --include={config.xml,sonarr.db} "${RCLONE_OPTIONS[@]}" 2>&1)
  curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?; fi
if [[ $service == 'tautulli' ]]; then
  HC_URL=https://hc-ping.com/
  curl -fsS --retry 5 $HC_URL/start
  o=$(rclone copy /opt/Tautulli mydrive:Backup/tautulli --include={tautulli.db,config.ini} "${RCLONE_OPTIONS[@]}" 2>&1)
  curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?; fi
