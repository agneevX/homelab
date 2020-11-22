#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi

HC_URL=https://hc-ping.com/

curl -fsS --retry 5 $HC_URL/start
o=$(rclone copy /opt/Tautulli personal:Backup/tautulli --include={tautulli.db,config.ini} --retries 60 --retries-sleep 30s 2>&1)
curl -fsS --retry 5 --data-raw "$o" $HC_URL/$?