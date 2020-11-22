#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi

RCLONE_CONFIG=/home/agneev/.config/rclone/rclone.conf
export RCLONE_CONFIG
HC_URL=https://hc-ping.com/

curl -fsS --retry 5 $HC_URL/start
o=$(rclone copy "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db" personal:Backup/plex 2>&1)
curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?