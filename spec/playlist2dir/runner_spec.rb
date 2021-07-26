# frozen_string_literal: true

require 'tempfile'
require 'yaml'

describe Playlist2Dir::Runner do
  context '.initialize' do
    it 'should parse command line args into basedir, playlist_file, and phone_root' do
      runner = Playlist2Dir::Runner.new('foo', 'bar.m3u8', '/phone/root')
      expect(runner.basedir).to eq('foo')
      expect(runner.playlist_file).to eq('bar.m3u8')
      expect(runner.phone_root).to eq('/phone/root')
    end
  end

  context '.dest_dir' do
    it 'should be the basedir plus _generated' do
      runner = Playlist2Dir::Runner.new('foo', 'bar', 'biz')
      expect(runner.dest_dir).to eq('foo/_generated')
    end
  end

  context '.output_playlist' do
    it 'should be the _generated dir plus the output_filename from the config' do
      playlist_filename = File.join(fixture_dir('playlists'), 'valid.m3u8')
      runner = Playlist2Dir::Runner.new('foo', playlist_filename, '/phone/root/')
      expect(runner.output_playlist).to eq('foo/_generated/a_playlist.m3u8')
    end
  end

  context '.run!' do
    before :example  do
      @basedir = Dir.mktmpdir('base')
      @playlist_tmpdir = Dir.mktmpdir('other')

      FileUtils.cp_r fixture_dir('tracks'), @basedir
      @tracks_dir = File.join(@basedir, 'tracks')

      FileUtils.cp_r fixture_dir('playlists'), @playlist_tmpdir
      playlist_dir = File.join(@playlist_tmpdir, 'playlists')
      @playlist_filename = File.join(playlist_dir, 'valid.m3u8')

      config_filename = File.join(playlist_dir, 'valid-config.yml')
      File.open(config_filename, 'w') do |f|
        config_yaml = {:output_filename => 'a_playlist.m3u8',
                       :remove_root => '/prefix'}.to_yaml
        f.print(config_yaml)
      end
    end

    after :example do
      [@basedir, @playlist_tmpdir].each do |d|
#        FileUtils.remove_entry d if d
      end
    end

    it 'should make a playlist with the paths adjusted (remove_root->phone_root)' do
      phone_root = '/a/phone/mp3/dir'
      runner = Playlist2Dir::Runner.new(@tracks_dir, @playlist_filename, phone_root)
      runner.run!

      expected_rewritten_playlist_contents =
        "/a/phone/mp3/dir/A-C/A Band/01. A song.mp3\n" +
        "/a/phone/mp3/dir/U-Z/Your Favorite Band/09. That Hit Song.flac\n" +
        "/a/phone/mp3/dir/L-M/My Favorite Band/22. That Hidden Track.ogg\n"

      rewritten_playlist_contents = nil
      File.open(runner.output_playlist) do |f|
        rewritten_playlist_contents = f.read
      end

      expect(rewritten_playlist_contents).to eq(expected_rewritten_playlist_contents)
    end

    it 'should make hard links in the dest_dir that point to all playlist entries' do
      phone_root = '/a/phone/mp3/dir'
      runner = Playlist2Dir::Runner.new(@tracks_dir, @playlist_filename, phone_root)
      runner.run!

      expected_hardlink_paths =
        ["#{runner.dest_dir}/A-C/A Band/01. A song.mp3",
         "#{runner.dest_dir}/U-Z/Your Favorite Band/09. That Hit Song.flac",
         "#{runner.dest_dir}/L-M/My Favorite Band/22. That Hidden Track.ogg"]

      expect(File.exists?(expected_hardlink_paths[0])).to be_truthy
      expect(File.exists?(expected_hardlink_paths[1])).to be_truthy
      expect(File.exists?(expected_hardlink_paths[2])).to be_truthy
    end

  end
end
