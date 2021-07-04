# frozen_string_literal: true

module Fixture
  def nonexistent_path
    '/tmp/sdfasdjflksadjflaskdjfal'
  end

  def fixture(filename)
    f = fixture_path filename
    raise "Not a plain file: #{f}" unless File.file?(f)
    f
  end

  def fixture_dir(dirname)
    d = fixture_path dirname
    raise "Not a directory: #{d}" unless File.directory?(d)
    d
  end

  private

  def fixture_path(filename)
    p = File.join(__dir__, '..', 'fixtures', filename)
  end
end
