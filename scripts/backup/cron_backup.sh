#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi

RCLONE_CONFIG=/home/agneev/.config/rclone/rclone.conf
export RCLONE_CONFIG
HC_URL=https://hc-ping.com/

curl -fsS --retry 5 $HC_URL/start
o=$(sudo rclone copy /var/spool/cron/crontabs/ personal:Backup/cron_jobs --config=/home/agneev/.config/rclone/rclone.conf --retries 60 --retries-sleep 30s 2>&1)
curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?