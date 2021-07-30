# frozen_string_literal: true
# encoding: UTF-8

require 'fileutils'
require 'tempfile'

describe Playlist2Dir::Playlist do
  context '.initialize' do
    before :example do
      @playlist_dir = Dir.mktmpdir('playlists')
    end

    after :example do
      FileUtils.remove_entry @playlist_dir if @playlist_dir
    end

    it 'should verify that the playlist file exists' do
      playlist_path = File.join(@playlist_dir, 'a_playlist.m3u8')
      expect{ Playlist2Dir::Playlist.new(playlist_path) }.to raise_error(/not found/)

      FileUtils.touch(playlist_path)
      expect{ Playlist2Dir::Playlist.new(playlist_path) }.not_to raise_error
    end
  end

  context '.each' do
    it 'should pass each non-comment line in the playlist to a block' do
      expected_lines = [
        "/prefix/A-C/A Band/01. A song.mp3",
        "/prefix/U-Z/Your Favorite Band/09. That Hit Song Chegan\x63\xCC\xA7a.flac",
        "/prefix/L-M/My Favorite Band/22. That Hidden Track.ogg"
      ]

      playlist = Playlist2Dir::Playlist.new(fixture('playlists/valid.m3u8'))
      lines = []
      playlist.each{|l| lines.push l}
      expect(lines).to eq(expected_lines)
    end
  end

  context '.length' do
    it 'should return the number of non-comment lines in the playlist' do
      playlist = Playlist2Dir::Playlist.new(fixture('playlists/valid.m3u8'))
      expect(playlist.length).to eq(3)
    end
  end
end
