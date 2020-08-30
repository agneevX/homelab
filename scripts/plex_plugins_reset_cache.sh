#!/bin/bash

sudo rm -r "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Caches/"*
sudo systemctl restart plexmediaserver