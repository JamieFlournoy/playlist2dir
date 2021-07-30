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

      unless File.exist?(repathed_source_file)
        # Try to handle iTunes' bizarrely inconsistent encoding of
        # characters such as C-with-cedilla as a single code point
        # (U+00E7 LATIN SMALL LETTER C WITH CEDILLA) or as a double
        # code point (U+0063 "LATIN SMALL LETTER C" followed by U+0327
        # "COMBINING CEDILLA"). Also U with umlaut and Y with umlaut.
        repathed_source_file = try_find_with_unicode_alternatives(repathed_source_file)
      end

      unless File.exist?(repathed_source_file)
        dir = File.dirname(repathed_source_file)
        puts "can't find '#{repathed_source_file}. Contents of '#{dir}':"
        Dir.new(dir).each{|f| puts "'#{f}'"}
      end

      link_already_exists = false
      if File.exist?(dest_file)
        src_inode_num = File.stat(repathed_source_file).ino
        dest_inode_num = File.stat(dest_file).ino
        raise "File '#{dest_file}' exists and is not a link to '#{repathed_source_file}'" if (src_inode_num != dest_inode_num)
        link_already_exists = true
      end

      unless link_already_exists
        FileUtils.mkdir_p(File.dirname(dest_file))
        FileUtils.ln(repathed_source_file, dest_file)
      end
      FileUtils.chmod(0440, dest_file)
    end

    private

    ENCODING_ALTERNATIVES = [
      ["\xC3\xA7", "\x63\xCC\xA7"],
      ["\xC3\xBC", "\x75\xCC\x88"],
      ["\xC3\xBF", "\x79\xCC\x88"],
      ["\xC3\xB6", "\x6F\xCC\x88"],
      ["\xC3\xAD", "\x69\xCC\x81"],
      ["\xC3\xA9", "\x65\xCC\x81"],
      ["\x3F", "\xEF\x80\xA5"],
      ["\xC3\xA4", "\x61\xCC\x88"]
    ]

    def try_find_with_unicode_alternatives(path)
      ENCODING_ALTERNATIVES.each do |alts|
        alts.each_with_index do |e,i|
          if path.include?(e)
            alts.each_with_index do |q,j|
              next if (j == i) || (q.empty? || e.empty?)
              attempt = path.gsub(e,q)
              return attempt if File.exist?(attempt)
              path = attempt
            end
          end
        end
      end

      path
    end
  end
end
