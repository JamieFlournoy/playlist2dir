# frozen_string_literal: true

describe Playlist2Dir::Config do
  before :example do
    @valid_opts = {:remove_root => '/foo', :output_dir => '/bar'}
  end

  context '.initialize' do
    it 'should require an :output_dir option' do
      @valid_opts.delete(:output_dir)
      expect{ Playlist2Dir::Config.new(@valid_opts) }.to raise_error(/output_dir/i)
    end

    it 'should require a :remove_root option' do
      @valid_opts.delete(:remove_root)
      expect{ Playlist2Dir::Config.new(@valid_opts) }.to raise_error(/remove_root/i)
    end

    it 'should require a non-empty :output_dir option'
    it 'should require a non-empty :remove_root option'
end

  context '.from_yaml_near_playlist' do
    it 'should automatically pick a YAML filename'
    it 'should read the constructor options from the file'
  end
end
