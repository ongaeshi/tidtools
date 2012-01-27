# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/01/27

require 'test_helper'
require 'tidtools/tiddler2texts_cli'

class TestTiddler2textsCli < Test::Unit::TestCase
  def test_noarg
    io = StringIO.new
    Tidtools::Tiddler2textsCli.execute(io, [])
    assert_match /tiddlywiki/, io.string
  end
end


