#!/bin/bash
# shellcheck disable=SC2001

if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then echo "Already running!"; exit 1; fi
now="$(date +'%d%m%S')"

if [[ "$1" == "-d" ]]; then set -x
else
	HC_URL=https://hc-ping.com/
	curl -fsS --retry 5 $HC_URL/start
fi

disk_usage="$(df --output=pcent / | awk -F '%' 'NR==2{print $1}')"

if [[ $1 == '-f' ]] || [[ $1 == '--force' ]]; then
	printf "Force flag found, moving all files\n"
elif [[ $disk_usage -gt '90' ]]; then
	MIN_AGE="--min-age=2d"
elif [[ $disk_usage -gt '80' ]] && [[ $disk_usage -lt '90' ]]; then
	MIN_AGE="--min-age=5d"
else
	MIN_AGE="--min-age=10d"
fi

subtitles_move () {
	rclone move -q /opt/.drive crypt: --include=*.srt --transfers=12 --filter '- local/**'
}

files_move () {
	rclone move ${MIN_AGE:+"$MIN_AGE"} ${BW_LIMIT:+"$BW_LIMIT"} \
	/opt/.drive crypt: \
	--filter '- .*' \
	--drive-chunk-size 64M \
	--delete-empty-src-dirs \
	--transfers=2 \
	--order-by "modtime,ascending" \
	--filter '- local/**' \
	--exclude-from=/tmp/exclude_"$now" \
	-v --stats-one-line --stats=6h 
}

subtitles_move &

find /opt/.drive/ -type f -links +1 -printf "/%P\n" > /tmp/exclude_"$now"
MOVE=$(files_move 2>&1)
exit_status=$?

body="$(echo -e "--- $disk_usage% SSD use ---\n$MOVE")"

curl -fsS -m 10 --retry 5 $HC_URL/$exit_status --data-raw "$body"
