#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi

RCLONE_CONFIG=/home/agneev/.config/rclone/rclone.conf
export RCLONE_CONFIG
HC_URL=https://hc-ping.com/

curl -fsS --retry 5 $HC_URL/start
o=$(rclone copy --include={radarr.db,config.xml} --retries 30 --retries-sleep 15s /home/agneev/.config/Radarr personal:Backup/radarr 2>&1)
curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?