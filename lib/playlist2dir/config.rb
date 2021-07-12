# frozen_string_literal: true

require 'yaml'

module Playlist2Dir
  class Config
    SUFFIX = '-config.yml'

    def self.from_yaml_near_playlist(playlist_path)
      File.open(yaml_filename_for(playlist_path)) do |y|
        obj = from_yaml(y.read)
        Playlist2Dir::Config.new(obj[0].transform_keys(&:to_sym))
      end
    end

    def self.yaml_filename_for(playlist_path)
      if File.extname(playlist_path) == ''
        playlist_path + SUFFIX
      else
        playlist_path.sub(/\.[^\.]+$/, SUFFIX)
      end
    end

    def self.from_yaml(config_yaml)
      YAML.load(config_yaml)
    end

    attr_reader :output_dir, :remove_root

    def initialize(opts = {})
      @output_dir = require_key(opts, :output_dir)
      @remove_root = require_key(opts, :remove_root)
    end

    def ==(other)
      other.respond_to?(:output_dir) &&
        other.respond_to?(:remove_root) &&
        other.remove_root == @remove_root &&
        other.output_dir == @output_dir
    end
    alias_method :eql?, :==

    private
    def require_key(obj, k)
      val = obj[k.to_sym]
      raise "The #{k} option is required" unless val
      raise "The #{k} option cannot be an empty string" if val.eql?('')
      val
    end
  end
end
