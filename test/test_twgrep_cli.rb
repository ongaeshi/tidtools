require 'test_helper'
require 'tidtools/twgrep_cli'

class TestTwgrepCli < Test::Unit::TestCase
  def test_noarg
    io = StringIO.new
    Tidtools::TwgrepCli.execute(io, [])
    assert_match /twgrep/, io.string
  end
end
