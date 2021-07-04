# frozen_string_literal: true

describe Playlist2Dir::Config do
  context '.initialize' do
    it 'should require an :output_dir option'
    it 'should require a :remove_root option'
  end
end
