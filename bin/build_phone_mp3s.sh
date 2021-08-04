#!/bin/bash

if [ $(uname) != "Linux" ]; then
    echo "Run this on the Linux host where the tracks are stored."
    exit 1
fi

SDCARD_VOLUME_SERIAL_NUMBER=2667-B8DA

sudo /usr/local/mp3s/_scripts/playlist2dir/bin/playlist2dir \
     /usr/local/mp3s/ \
     /usr/local/mp3s/_playlists/_Sync\ to\ iPod.m3u8 \
     /storage/$SDCARD_VOLUME_SERIAL_NUMBER/Music/Mp3sForPhone/

echo "Now you may want to run this command on the Mac if you're copying to a mounted SD card:"
echo "rsync -rtxi --delete /Volumes/mp3/_generated/ /Volumes/android/Music/Mp3sForPhone/"


