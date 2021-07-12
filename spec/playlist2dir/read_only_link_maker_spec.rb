# frozen_string_literal: true

require 'fileutils'
require 'tempfile'

TEST_MTIME=946598401
MP3_CONTENTS='Test file'

describe Playlist2Dir::ReadOnlyLinkMaker do
  context '.write_for' do
    before :example do
      @src_dir =  Dir.mktmpdir('src')
      @dest_dir = Dir.mktmpdir('dest')

      src_subdir = File.join(@src_dir, 'foo', 'bar')
      @src_filename = File.join(src_subdir, 'test.mp3')
      @expected_dest_filename =
        File.join(@dest_dir, 'foo', 'bar', 'test.mp3')

      FileUtils.mkdir_p(src_subdir, mode: 0700)
      File.open(@src_filename, 'w+'){|mp3| mp3.write(MP3_CONTENTS) }
      FileUtils.touch(@src_filename, mtime: TEST_MTIME)

      @conf = stub(:remove_root => @src_dir, :output_dir => @dest_dir)
    end

    after :example do
      FileUtils.remove_entry @src_dir if @src_dir
      FileUtils.remove_entry @dest_dir if @dest_dir
    end

    it 'should create a hard link' do
      rolm = Playlist2Dir::ReadOnlyLinkMaker.new(@conf)
      rolm.write_for(@src_filename)

      open(@expected_dest_filename) do
        |f| contents = f.read
        expect(contents).to eq MP3_CONTENTS
      end
    end

    it 'should set file mode 440 on the hard link' do
      rolm = Playlist2Dir::ReadOnlyLinkMaker.new(@conf)
      rolm.write_for(@src_filename)

      mode = File.stat(@expected_dest_filename).mode & 0777
      expect(sprintf("%o", mode)).to eq '700'
    end

    it 'should copy the modification time from the source file' do
      rolm = Playlist2Dir::ReadOnlyLinkMaker.new(@conf)
      rolm.write_for(@src_filename)

      expect(File.stat(@expected_dest_filename).mtime.to_i).to eq TEST_MTIME
    end
  end
end
