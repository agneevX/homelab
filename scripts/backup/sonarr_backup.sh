#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi

HC_URL=https://hc-ping.com/

curl -fsS --retry 5 $HC_URL/start
o=$(rclone copy --include={config.xml,sonarr.db} /var/lib/sonarr personal:Backup/sonarr --retries 30 --retries-sleep 15s 2>&1)
curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?