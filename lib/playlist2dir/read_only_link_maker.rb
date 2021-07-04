# frozen_string_literal: true

module Playlist2Dir
  class ReadOnlyLinkMaker
    def initialize(config)
      @remove_root = config.remove_root
      @output_dir = config.output_dir
    end

    def write_for(source_file)
      if !source_file.start_with?(@remove_root)
        raise "Source file #{source_file} does not start with #{@remove_root}"
      end
      relpath = source_file[@remove_root.length..-1]
      dest_file = File.join(@output_dir, relpath)
      FileUtils.mkdir_p(File.dirname(dest_file))
      FileUtils.ln(source_file, dest_file)
      FileUtils.chmod(0700, dest_file)
    end
  end
end
