# frozen_string_literal: true

module Playlist2Dir
  class ReadOnlyLinkMaker
    def initialize(remove_root, src_dir, output_dir)
      @remove_root = remove_root
      @src_dir = src_dir
      @output_dir = output_dir
    end

    def write_for(source_file)
      if !source_file.start_with?(@remove_root)
        raise "Source file #{source_file} does not start with #{@remove_root}"
      end
      relpath = source_file[@remove_root.length..-1]
      repathed_source_file = File.join(@src_dir, relpath)
      dest_file = File.join(@output_dir, relpath)
      FileUtils.mkdir_p(File.dirname(dest_file))
      FileUtils.ln(repathed_source_file, dest_file)
      FileUtils.chmod(0700, dest_file)
    end
  end
end
