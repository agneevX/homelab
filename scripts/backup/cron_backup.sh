#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi

RCLONE_CONFIG=/home/agneev/.config/rclone/rclone.conf
export RCLONE_CONFIG
url=https://hc-ping.com/xxxxx

curl -fsS --retry 3 $url/start
o=$(sudo rclone copy /var/spool/cron/crontabs/ personal:Backup/cron_jobs --config=/home/agneev/.config/rclone/rclone.conf --retries 60 --retries-sleep 30s 2>&1)
if [ $? -ne 0 ]; then url=$url/fail; fi
curl -fsS --retry 3 --data-raw "$o" $url