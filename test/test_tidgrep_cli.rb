require 'test_helper'
require 'tidtools/tidgrep_cli'

class TestTidgrepCli < Test::Unit::TestCase
  def test_noarg
    io = StringIO.new
    Tidtools::TidgrepCli.execute(io, [])
    assert_match /tidgrep/, io.string
  end
end
