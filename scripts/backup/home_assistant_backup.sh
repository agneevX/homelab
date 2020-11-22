#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi

RCLONE_CONFIG=/home/agneev/.config/rclone/rclone.conf
export RCLONE_CONFIG
HC_URL=https://hc-ping.com/
options=(--transfers=10 --exclude-from=/home/homeassistant/.ha_excludes --retries 60 --retries-sleep 30s)

curl -fsS --retry 5 $HC_URL/start
o=$(sudo rclone sync /home/homeassistant personal:Backup/home-assistant "${options[@]}" --config=/home/agneev/.config/rclone/rclone.conf 2>&1)
curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?

