# frozen_string_literal: true

require 'tempfile'

describe Playlist2Dir::Config do
  before :example do
    @valid_opts = {:remove_root => '/foo', :output_filename => 'test.m3u8'}
  end

  context '.initialize' do
    it 'should require an :output_filename option' do
      @valid_opts.delete(:output_filename)
      expect{ Playlist2Dir::Config.new(@valid_opts) }.to raise_error(/output_filename/i)
    end

    it 'should require a non-empty :output_filename option' do
      @valid_opts.delete(:output_filename)
      expect{ Playlist2Dir::Config.new(@valid_opts) }.to raise_error(/output_filename/i)
    end

    it 'should require a :remove_root option' do
      @valid_opts[:remove_root] = ''
      expect{ Playlist2Dir::Config.new(@valid_opts) }.to raise_error(/remove_root/i)
    end

    it 'should require a non-empty :remove_root option' do
      @valid_opts[:remove_root] = ''
      expect{ Playlist2Dir::Config.new(@valid_opts) }.to raise_error(/remove_root/i)
    end
  end

  context '.yaml_filename_for' do
    it 'should automatically pick a YAML filename' do
      yaml_filename = Playlist2Dir::Config.yaml_filename_for('/foo/bar/biz.baz.m3u')
      expected_yaml_filename = '/foo/bar/biz.baz-config.yml'
      expect(yaml_filename).to eql(expected_yaml_filename)

      yaml_filename = Playlist2Dir::Config.yaml_filename_for('/foo/bar/playlist')
      expected_yaml_filename = '/foo/bar/playlist-config.yml'
      expect(yaml_filename).to eql(expected_yaml_filename)
    end

  end

  context '.from_yaml_near_playlist' do
    it 'should read the constructor options from the file' do
      yaml_to_write = "---\nremove_root: /foo\noutput_filename: /bar\n"
      options = {:output_filename => '/bar', :remove_root => '/foo'}
      expected_conf = Playlist2Dir::Config.new(options)

      begin
        srcdir = Dir.mktmpdir('playlists')
        playlist_file_name = File.join(srcdir, 'test.m3u8')
        FileUtils.touch(playlist_file_name)
        conf_file_name = File.join(srcdir, 'test-config.yml')
        File.write(conf_file_name, yaml_to_write)

        conf = Playlist2Dir::Config.from_yaml_near_playlist(playlist_file_name)
        expect(conf).to eql(expected_conf)
      ensure
        FileUtils.remove_entry(srcdir) if (srcdir && File.exist?(srcdir))
      end
    end
  end
end
