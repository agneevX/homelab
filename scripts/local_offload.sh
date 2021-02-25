#!/bin/bash
set -e
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then
echo "Already running, exiting..."; exit 1; fi
now="$(date +'%d%m%S')"

if [[ $1 == '-t' ]] || [[ $1 == '--test' ]]; then
  echo "Test - drive_offload.sh."; exit 1; fi

if [[ $1 == '-f' ]] || [[ $1 == '--force' ]]; then
  echo "force flag found... moving all files..."; MIN_AGE=""
else MIN_AGE="--min-age=7d"; fi

HC_URL=https://hc-ping.com/

curl -fsS --retry 5 $HC_URL/start
find /opt/.drive/ -type f -links +1 -printf "/%P\n" > /tmp/lo_exclude_"$now"
o=$(rclone move /opt/.drive --bwlimit=6M --transfers=1 crypt: "$MIN_AGE" --exclude local/** --filter '- .*' --exclude-from=/tmp/lo_exclude_"$now" --order-by "size,mixed,25" --drive-chunk-size 64M -v --stats-one-line --stats=15m --delete-empty-src-dirs --fast-list 2>&1)
curl -fsS -m 10 --retry 5 --data-raw "$o" "$HC_URL"/$?
