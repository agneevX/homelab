# Shortcut to edit cron jobs
alias ct='crontab -e'
alias sudo='sudo '
alias ll='df -h -x tmpfs -x devtmpfs'
alias up='sudo apt update && sudo apt upgrade -y'
alias port='sudo lsof -i -P -n | grep LISTEN | grep v4'

alias gdns='ping dns.google'
alias mkdir='mkdir -pv'
alias vnstat='vnstat -i eth0'
alias mv="mv -v"
alias rm="rm -v"
alias cp="cp -v"

# Outputs current public IP address
alias myip='dig TXT +short o-o.myaddr.l.google.com @ns1.google.com'

# Refreshes all Plex libraries
alias plex='for id in {1,12,16,2,11} ; do curl http://127.0.0.1:32400/library/sections/${id}/refresh?X-Plex-Token=xxxx ; done'

alias ncdu='ncdu -q'
alias hh='bashtop'

# Easy access to important Home Assistant config files
alias conf="sudo nano /home/homeassistant/.homeassistant/configuration.yaml"
alias auto="sudo nano /home/homeassistant/.homeassistant/automations.yaml"
alias cust="sudo nano /home/homeassistant/.homeassistant/customize.yaml"
alias hass="cd /home/homeassistant/.homeassistant"