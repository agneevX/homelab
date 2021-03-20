#!/bin/bash
# shellcheck disable=SC2001
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then
echo "Already running, exiting..."; exit 1; fi
now="$(date +'%d%m%S')"
disk_usage="$(df --output=pcent / | awk -F '%' 'NR==2{print $1}')"
disk_info=$(echo "---$disk_usage% SSD USAGE---" && printf "\n\n")
OPTIMIZE_FLAGS=(--drive-chunk-size 64M --delete-empty-src-dirs --fast-list -v --stats-one-line --stats=5h)
RCLONE_FLAGS=(--max-transfer=60G --order-by "modtime,ascending" --cutoff-mode=soft --transfers=1 --filter '- local/**' --filter '- .*' --exclude-from=/tmp/lo_exclude_"$now")

if [[ $1 == '-f' ]] || [[ $1 == '--force' ]]; then
  printf " + Force flag found, moving all files\n"
  MIN_AGE=""
elif [[ $disk_usage -gt '90' ]]; then
  MIN_AGE="--min-age=3d"
elif [[ $disk_usage -gt '80' ]] && [[ $disk_usage -lt '90' ]]; then
  MIN_AGE="--min-age=5d"
else MIN_AGE="--min-age=7d"; fi

if [[ $1 == '-fb' ]] || [[ $1 == '--force-bandwidth' ]]; then
  printf " + Not enabling bandwidth limiter...\n"; BW_LIMIT=""
else BW_LIMIT="--bwlimit=6M"; fi

HC_URL=https://hc-ping.com/
curl -fsS --retry 5 $HC_URL/start

find /opt/.drive/ -type f -links +1 -printf "/%P\n" > /tmp/lo_exclude_"$now"

o=$(echo "$disk_info" && rclone move "$MIN_AGE" "$BW_LIMIT" /opt/.drive crypt: "${RCLONE_FLAGS[@]}" "${OPTIMIZE_FLAGS[@]}" 2>&1)
exit_status=$?
o="$(echo "$o" | sed 's/\&/%26/g')" && o="$(echo "$o" | sed 's/\@/%40/g')"

if [[ $exit_status == '8' ]]; then exit_status='0'; fi
curl -fsS -m 10 --retry 5 --data-raw "$o" $HC_URL/$exit_status
