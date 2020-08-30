### Tested on Debian Buster - ARM - Raspberry Pi 4

#!/bin/bash
set -e
echo " + Installing unzip

"
sudo apt -y install unzip
clear

echo " + Downloading Plex-trakt-scrobbler

"
wget https://github.com/rg9400/Plex-Trakt-Scrobbler/archive/master.zip -O /tmp/Plex-Trakt-Scrobbler.zip
unzip /tmp/Plex-Trakt-Scrobbler.zip
echo " + Copying to Plex folder

"
sudo cp -r /tmp/Plex-Trakt-Scrobbler-*/Trakttv.bundle "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/"

# Downloading apsw.so and trakt databases
echo " + Downloading and unzipping trakt.zip from Dropbox

"
wget https://www.dropbox.com/s/8139onakej9xfyj/trakt.zip?dl=1 -O /tmp/trakt.zip
unzip /tmp/trakt.zip

# Copying databases and changing ownership
sudo cp /tmp/trakt/apsw.so /usr/lib/plexmediaserver/Resources/Python/lib/python2.7/lib-dynload
sudo cp /tmp/trakt/com.plexapp.plugins.trakttv.db /tmp/trakt/com.plexapp.plugins.trakttv.db-shm /tmp/trakt/com.plexapp.plugins.trakttv.db-wal \
"/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases"
cd "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases"
sudo chown plex:plex com.plexapp.plugins.trakttv.db com.plexapp.plugins.trakttv.db-shm com.plexapp.plugins.trakttv.db-wal
sudo chmod 644 com.plexapp.plugins.trakttv.db com.plexapp.plugins.trakttv.db-shm com.plexapp.plugins.trakttv.db-wal
cd
sudo systemctl restart plexmediaserver
echo "Trakt is now installed."
