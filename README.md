# Overview

**playlist2dir** is a program for Linux that will create a directory of audio files that are listed as tracks in an .m3u8 playlist.

To save disk space and avoid unnecessary file copying, the audio files that playlist2dir creates are actually hard linked to the original files.

(If you aren't familiar with hard links, they are multiple directory entries that all refer to the same data on disk - unlike a symbolic link, there is no "main" hard link to a file. They are all equally "real".)

This means that the directory it creates takes up almost no extra disk space, but it must be located on the same volume as the files described in the playlist.

## Suitability

This program was by the author for personal use, to solve a very specific problem: carefully rated and curated playlists made in iTunes on a Mac, referring to a large MP3 collection stored on a Linux file server, which the author wants to copy to a mobile phone en masse in a way that audio player apps can consume easily.

If you have exactly this problem, it may be useful for you. If not, it probably won't.


# Setup

## Disk layout

### Where the tracks are

*Tracks* are the audio files, in MP3 format or any other format that is stored in a local file, that are referenced by the playlist.

You must first ensure that all of the tracks  in the playlist are located on one volume together. If this is not the case, you will need to split the playlist into one playlist per volume of tracks.

Second, you will need to have one of the following:

- read-write access to output directory (see below) _and_ ownership of all the files containing tracks

- sudo access to allow you to create hard links to files your user does not own

These limitations are caused by the use of hard links - you can't make a hard link to a file you don't have access to (because that would give you access to it).

### The playlist format

You will need to create an .m3u8 (it's just an M3U playlist that's encoded in UTF-8) file with Mac line endings (ctrl-M, not ctrl-J as in Unix text files or ctrl-M ctrl-J as in Windows/DOS text files).

This happens to be the format that iTunes for the Mac exports in.

Again, the playlist can only contain tracks that are all located on one volume. (The playlist does not have to be on this volume.)

### The playlist2dir config file

For each playlist, two additional values are needed, and are found in the config file which must be located in the same directory as the playlist, with the same name as the playlist except with the suffix `-config.yml` instead of `.m3u8`.

The config file is a YAML file containing two values: `output_filename` and `remove_root`.

`output_filename` controls what the filename will be for the generated playlist at the top level of the output directory. Example value: MyPlaylist.m3u8

`remove_root` allows the input playlist to contain track paths that assume that the track collection is on a mounted volume, in which case the paths in the playlist are probably not correct from the point of view of playlist2dir running on the Linux host. The value of `remove_root` will be replaced with the value of the third command line argument when creating the output playlist file.

### Where the output will go

The tracks will be "copied" (hard linked, actually) to an output directory, and will retain their directory structure relative to the root directory of the track collection (as specified by the user via the 1st command line argument).

The output directory is determined by adding "/_generated/" to the root directory of the track collection.

A playlist file will be created which contains all of the tracks that were copied, with their paths adjusted to point to where the files will go on the phone. This means that, assuming the user provides the correct paths when running the command, the playlist can be copied to the phone and should work as-is to play all of the tracks.


# Running

The playlist2dir executable takes three command line arguments:

1. The root directory of the track collection. This can be the root of the volume or a subdirectory, as long as all of the track files in the playlist are contained in this directory.

2. The playlist file's path. This can be anywhere on the system that playlist2dir is running on.

3. The path on the Android phone to where the MP3 collection for this playlist will end up.

# Usage example:

A Linux host has a collection of MP3 files in `/usr/local/mp3s/`, exported via Samba as the SMB volume `mp3s`. A Mac laptop mounts this at `/Volumes/mp3s/`, and the user imports the files into iTunes and creates a playlist by hand. The user exports the playlist as `MyPlaylist.m3u8` on the Mac, and copies that to `/home/someuser/MyPlaylist.m3u8` on the Linux host.

The user creates a playlist2dir config file located at `/home/someuser/MyPlaylist-config.yml` containing the following:

```
---
remove_root: /Volumes/mp3/
output_filename: MyPhonePlaylist.m3u8
```

The user installs playlist2dir at /usr/local/mp3s/_scripts/playlist2dir.

The user runs playlist2dir as follows:

```
sudo /usr/local/mp3s/_scripts/playlist2dir/bin/playlist2dir \
     /usr/local/mp3s/ \
     /home/someuser/MyPlaylist.m3u8 \
     /storage/1234-ABCD/Music/MP3sForPhone/
```

The playlist at `/home/someuser/MyPlaylist.m3u8` is read. All of the files have paths that look like `/Volumes/mp3/Artist/Album/01. Track name.mp3`, since it was generated by iTunes and those are the paths it uses to access those tracks.

Since this is not the correct path from the Linux host's point of view, playlist2dir uses the `remove_root` value from the config file along with the first command line argument to determine the path on the Linux host to the track file (`/usr/local/mp3s/Artist/Album/01. Track name.mp3` in this example).

Again using the first command line argument, playlist2dir creates hard-linked "copies" using `/usr/local/mp3s/_generated` as the root directory for output. So there is now a `/usr/local/mp3s/_generated/Artist/Album/01. Track name.mp3`. This is repeated for every track in the playlist.

A playlist file is created at `/usr/local/mp3s/_generated/MyPhonePlaylist.m3u8` that contains paths intended for use on the mobile phone. These paths look like `/storage/1234-ABCD/Music/MP3sForPhone/Artist/Album/01. Track name.mp3`.

The user copies the contents of _generated to the phone's storage at `/storage/1234-ABCD/Music/MP3sForPhone/`, and now the playlist at `/storage/1234-ABCD/Music/MP3sForPhone/MyPhonePlaylist.m3u8` is correct and can be used from an audio player on the phone.

## Multiple playlists

The intent of playlist2dir is to allow the user to make multiple playlists on the desktop/server and then to export those to the phone along with the tracks. Tracks that are on multiple playlists will be shared among those playlists, appearing only once in the _generated directory.

# License and Contact

See [LICENSE.txt](LICENSE.txt).

If you're feeling frisky and don't mind filing bugs and pull requests against a personal project that probably will not be maintained much, feel free to scream into the void at [https://github.com/JamieFlournoy/playlist2dir](https://github.com/JamieFlournoy/playlist2dir). If you fork this project and never tell me about it my feelings won't be hurt.

If you want to email me, use [jamie@pervasivecode.com](mailto:jamie@pervasivecode.com). 

