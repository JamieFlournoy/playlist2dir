# frozen_string_literal: true


describe Playlist2Dir::ReadOnlyLinkMaker do
#  before :example do

  context '.write' do
    it 'should create a hard link'
    it 'should set file mode 440 on the hard link'
    it 'should copy the modification time from the source file'
  end
end
