#!/bin/bash
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then exit; fi
export DEBIAN_FRONTEND=noninteractive
url=https://hc-ping.com/xxxxx

curl -fsS --retry 3 $url/start
o=$(sudo apt-get update && sudo apt-get -o Dpkg::Options::="--force-confnew" dist-upgrade -yqq 2>&1)
if [ $? -ne 0 ]; then url=$url/fail; fi
curl -fsS --retry 3 --data-raw "$o" $url