#!/bin/bash

now=$(date +'%d%m%S')

find "/home/ubuntu/drive-local" -type f -links +1 -printf "/%P\n" > /tmp/exclude_"$now"

rclone move /home/ubuntu/drive-local crypt: \
--transfers=4 \
--drive-chunk-size 64M \
--delete-empty-src-dirs \
--filter '- local/**' \
--exclude-from=/tmp/exclude_"$now"