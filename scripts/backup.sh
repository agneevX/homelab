#!/bin/bash
# shellcheck disable=SC2034,SC2086
set -e

if [[ -z "$1" ]]; then
	echo 'Not found'
	exit 1
elif [[ "$1" == "-d" ]]; then
	set -x
	service="$2"
else service="$1"
fi

CONFIG="/opt/appdata"

homeassistant="$CONFIG/home-assistant"
homeassistant_HC=""

tautulli="$CONFIG/tautulli --include=*.{db,ini} --include=backups/**"
tautulli_HC=""

radarr="$CONFIG/radarr --include={radarr.db,config.xml}"
radarr_HC=""

radarr4k="$CONFIG/radarr4k --include={radarr.db,config.xml}"
radarr4k_HC=""

sonarr="$CONFIG/sonarr --include={config.xml,sonarr.db}"
sonarr_HC=""

plexdb="$CONFIG/plexmediaserver/config/Plug-in Support/Databases/com.plexapp.plugins.library.db"
plexdb_HC=""

rclone_upload () {
	rclone copy "${!service}" mydrive:"$1" -v --retries 60 --retries-sleep 30s
}

healthchecks () {
	prefix="https://hc-ping.com"
	id=${service}_HC

	if [[ "$2" == "start" ]]; then
		curl -fs --retry 5 "$prefix/${!id}/start"
	else
		curl -fs --retry 5 --data-raw "$2" "$prefix/${!id}/$3"
	fi
}

healthchecks "$service" "start"

if [[ "$service" == "home-assistant" ]]; then
	printf ".local/\n.lesshst\n.cache/\ntmp/\n*.core\nhome-assistant_v2.db\nhome-assistant.log" > /tmp/hass_excludes
	o="$(rclone sync "${service[@]}" mydrive:"$service" --transfers=8 "--exclude-from=/tmp/hass_excludes" 2>&1)"
	exit_state=$?
else
	o=$(rclone_upload "$service" 2>&1)
	exit_state=$?
fi

healthchecks "$service" "$o" "$exit_state"
