alias sudo='sudo '
alias mv="mv -v"
alias rm="rm -v"
alias cp="cp -v"
alias mkdir='mkdir -pv'
alias lp='df -h -x tmpfs -x devtmpfs'
alias ct='crontab -e'
alias up='sudo apt update && sudo apt upgrade -y'
alias port='sudo lsof -i -P -n | grep LISTEN | grep v4'
alias op='ping 172.16.248.1'
alias gdns='ping dns.google'
alias vnstat='vnstat -i eth0'
alias ncdu='ncdu -q'

alias myip='dig TXT +short o-o.myaddr.l.google.com @ns1.google.com'
alias plex='for id in {1,12,16,2,11} ; do curl http://127.0.0.1:32400/library/sections/${id}/refresh?X-Plex-Token=xxxx ; done'

# Easy access to important Home Assistant config files
alias conf="sudo nano /home/homeassistant/.homeassistant/configuration.yaml"
alias auto="sudo nano /home/homeassistant/.homeassistant/automations.yaml"
alias cust="sudo nano /home/homeassistant/.homeassistant/customize.yaml"
alias hass="cd /home/homeassistant/.homeassistant"

# rclone common tasks
alias rcc="rclone copy --retries-sleep=15s -P --stats=1.5s --use-mmap"
alias rcm="rclone move --retries-sleep=15s -P --stats=1.5s --use-mmap"