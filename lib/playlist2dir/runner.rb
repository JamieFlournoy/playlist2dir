# frozen_string_literal: true

module Playlist2Dir
  class Runner

    attr_reader :basedir, :dest_dir, :phone_root, :playlist_file

    def initialize(basedir, playlist_file, phone_root)
      @basedir = basedir
      @dest_dir = File.join(basedir, '_generated')

      @playlist_file = playlist_file

      @phone_root =  phone_root

      @config = nil
      @output_playlist = nil
    end

    def output_playlist
      @output_playlist ||= File.join(@dest_dir, config.output_filename)
    end

    def run!
      @playlist_obj = Playlist.new(playlist_file)
      rolm = ReadOnlyLinkMaker.new(config.remove_root, @basedir, dest_dir)
      FileUtils.mkdir_p(dest_dir)

      File.open(output_playlist, 'w') do |output|
        @playlist_obj.each do |l|
          if (l.start_with?(@config.remove_root))
            i = config.remove_root.length
            output_line = "#{phone_root}#{l[i..-1]}\n"
            output.puts output_line
            puts output_line

            rolm.write_for(l)
          else
            STDERR.puts "Track has unexpected path prefix: #{l}"
          end
        end # each
      end # ->output
    end

    private

    def config
      @config ||= Config.from_yaml_near_playlist(@playlist_file)
    end

  end
end
