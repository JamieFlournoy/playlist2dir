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

      @remove_root = @src_dir
    end

    after :example do
      [@src_dir, @dest_dir].each do |d|
        FileUtils.remove_entry d if d
      end
    end

    it 'should complain & exit if the dest exists but isn\'t a link to the right file' do
      # Write an identical copy that isn't a hard link to the original file
      FileUtils.mkdir_p(File.dirname(@expected_dest_filename))
      File.open(@expected_dest_filename, 'w'){|mp3| mp3.write(MP3_CONTENTS) }

      rolm = Playlist2Dir::ReadOnlyLinkMaker.new(@remove_root, @src_dir, @dest_dir)
      expect{ rolm.write_for(@src_filename) }.to raise_error(/exists and is not a link/)
    end

    it 'should tolerate existing hard links if they are to the right file' do
      rolm = Playlist2Dir::ReadOnlyLinkMaker.new(@remove_root, @src_dir, @dest_dir)
      rolm.write_for(@src_filename)
      expect{ rolm.write_for(@src_filename)}.not_to raise_error
    end

    it 'should create a hard link' do
      rolm = Playlist2Dir::ReadOnlyLinkMaker.new(@remove_root, @src_dir, @dest_dir)
      rolm.write_for(@src_filename)

      open(@expected_dest_filename) do
        |f| contents = f.read
        expect(contents).to eq MP3_CONTENTS
      end
    end

    it 'should set file mode 440 on the hard link' do
      rolm = Playlist2Dir::ReadOnlyLinkMaker.new(@remove_root, @src_dir, @dest_dir)
      rolm.write_for(@src_filename)

      mode = File.stat(@expected_dest_filename).mode & 0777
      expect(sprintf("%o", mode)).to eq '440'
    end

    it 'should copy the modification time from the source file' do
      rolm = Playlist2Dir::ReadOnlyLinkMaker.new(@remove_root, @src_dir, @dest_dir)
      rolm.write_for(@src_filename)

      expect(File.stat(@expected_dest_filename).mtime.to_i).to eq TEST_MTIME
    end
  end
end
