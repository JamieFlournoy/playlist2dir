playlist2dir.rb:

Put an M3U playlist in _playlists.
Put a config file with the same base name +"-config.yml" in _playlists.
The following keys (and sample values) are required:
  remove_root: /Volumes/mp3/
  output_filename: myplaylist.m3u8

$ playlist2dir.rb /usr/local/mp3s /usr/local/mp3s/_playlists/foo.m3u /android/Music/mp3s/

# looks for /usr/local/mp3s/_playlists/foo-config.m3u
# Creates hard-link files in /usr/local/mp3s/_generated/A-C/ etc. Does not hard-link "._" files.
# - created with 440 file permissions
# - mod date adjusted to match source file
# - preexisting hard links are left alone
#
# copies modified playlist to /usr/local/mp3s/_generated/ with the name specified by output_filename in the config file.
# file paths in the playlist are modified by removing the leading "remove_root" value (from the configf file) and replacing it with the third command line argument (/android/Music/mp3s/ in the example command line above) which is the root of the MP3 folder on the phone's filesystem.
