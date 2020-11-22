#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi

HC_URL=https://hc-ping.com/
curl -fsS --retry 5 $HC_URL/start

LOG=(-v --stats-one-line --stats=15m)
BW=(--bwlimit '00:30,6M 19:00,5M 22:20,6M 23:00,5M')
FLAGS=(--drive-chunk-size 64M --transfers=1 --min-age 1d --delete-empty-src-dirs --fast-list)
EXCLUDES=(--exclude local/**)

o=$(/usr/bin/rclone move /opt/.drive drive: "${FLAGS[@]}" "${EXCLUDES[@]}" "${BW[@]}" "${LOG[@]}" 2>&1)
curl -fsS -m 10 --retry 5 --data-raw "$o" $HC_URL/$?
