# Modified version of Shantanu Goel's script
# to fix Raspberry Pi 4's issue with random Ethernet disconnects

# Runs every minute with cron

# !/bin/bash
now=$(date | sed 's/IST//g')
if ping -q -c 1 -W 1 10.0.0.1 > /dev/null; then
    echo "$now: Network is up" >> /home/agneev/logs/net_monitor.log
else
    sudo ethtool -r eth0
    echo "$now: Network down. Trying to restart eth0" >> /home/agneev/logs/net_monitor.log
fi