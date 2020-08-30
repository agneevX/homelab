#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi

RCLONE_CONFIG=/home/agneev/.config/rclone/rclone.conf
export RCLONE_CONFIG
url=https://hc-ping.com/xxxxx

curl -fsS --retry 3 $url/start
o=$(rclone copy /var/lib/sonarr personal:Backup/sonarr_backup --exclude={MediaCover/**,*log*,logs/**,*pid} --retries 60 --retries-sleep 30s 2>&1)
if [ $? -ne 0 ]; then url=$url/fail; fi
curl -fsS --retry 3 --data-raw "$o" $url