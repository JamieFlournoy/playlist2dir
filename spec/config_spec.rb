# frozen_string_literal: true

describe Playlist2Dir::Config do
  context '.initialize' do
    it 'should require an :output_dir option' do
      conf = {:remove_root => 'foo'}
      expect{ Playlist2Dir::Config.new(conf) }.to raise_error(/output_dir/i)
    end


    it 'should require a :remove_root option'
  end
end
