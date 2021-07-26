# frozen_string_literal: true

require 'yaml'

module Playlist2Dir
  class Config
    SUFFIX = '-config.yml'

    def self.from_yaml_near_playlist(playlist_path)
      File.open(yaml_filename_for(playlist_path)) do |y|
        contents = y.read
#        puts contents
        obj = from_yaml(contents)
#        puts "obj: #{obj.inspect}"

        Playlist2Dir::Config.new(obj.transform_keys(&:to_sym))
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

    attr_reader :output_filename, :remove_root

    def initialize(opts = {})
      @output_filename = require_key(opts, :output_filename)
      @remove_root = require_key(opts, :remove_root)
    end

    def ==(other)
      other.respond_to?(:output_filename) &&
        other.respond_to?(:remove_root) &&
        other.remove_root == @remove_root &&
        other.output_filename == @output_filename
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
