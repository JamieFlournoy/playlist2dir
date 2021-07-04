# frozen_string_literal: true

module Playlist2Dir
  class Config
    def initialize(opts = {})
      require_key(opts, :output_dir)
      require_key(opts, :remove_root)
    end

    private
    def require_key(obj, k)
      raise "The #{k} option is required" unless obj[k.to_sym]
    end
  end
end
