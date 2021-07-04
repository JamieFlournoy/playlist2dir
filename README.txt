playlist2dir.rb:

Put an M3U playlist in _playlists.
Put a config file with the same base name +"-config.yml" in _playlists.
  - remove_root: /Volumes/mp3/
    output_dir: /usr/local/mp3s/_generated/

$ playlist2dir.rb /usr/local/mp3s/_playlists/foo.m3u
#
# looks for /usr/local/mp3s/_playlists/foo-config.m3u
# Creates hard-link files in /usr/local/mp3s/_generated/A-C/ etc. Does not hard-link "._" files.
# - created with 440 file permissions
# - mod date adjusted to match source file
# - preexisting hard links are left alone
#
# copies relative-path-ized playlist to /usr/local/mp3s/_generated/ with same name as it originally had in _playlists
# - file paths are relative to the playlist, which is in the _generated/ folder. ex. "A-C/Alice in Chains/Dirt/08 Dirt.mp3".






