#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi

RCLONE_CONFIG=/home/agneev/.config/rclone/rclone.conf
export RCLONE_CONFIG
url=https://hc-ping.com/xxxxx
#source="/home/agneev/.config/Radarr"
#dest="personal:Backup/radarr_backup"
#move_old_files_to="dated_directory"
#options="--exclude={MediaCover/**,*log*,logs/**,*pid} --retries 60 --retries-sleep 30s"
#monitoring_url="https://hc-ping.com/xxxxx"

curl -fsS --retry 3 $url/start
o=$(rclone copy /home/agneev/.config/Radarr personal:Backup/radarr_backup --exclude={MediaCover/**,*log*,logs/**,*pid} --retries 60 --retries-sleep 30s 2>&1)
#bash /home/agneev/rclone_jobber/rclone_jobber.sh "$source" "$dest" "$move_old_files_to" "$options" "$(basename $0)" "$monitoring_url"
if [ $? -ne 0 ]; then url=$url/fail; fi
curl -fsS --retry 3 --data-raw "$o" $url