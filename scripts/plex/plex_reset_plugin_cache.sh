#!/bin/bash

sudo systemctl stop plexmediaserver
sudo rm -r "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Caches/"*
sudo systemctl start plexmediaserver
