# frozen_string_literal: true

module Playlist2Dir
  class Playlist

    def initialize(filename)
      raise "Playlist file not found at #{filename}" unless File.exist?(filename)
      @filename = filename
    end

    def each(&block)
      File.foreach(@filename, "\r", :encoding => 'bom|UTF-8') do |line|
        unless line.start_with?('#')
          block.yield line.chomp
        end
      end
    end

    def length
      count = 0
      self.each{ count += 1}
      count
    end
  end
end
