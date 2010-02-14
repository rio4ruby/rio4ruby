#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/rio/')
end
require "test/unit"
require 'alturi'

class Alt::URI::CreateTest < Test::Unit::TestCase
  
  def setup
    super
  end
  
  def teardown
    super
  end



  def test_starts_with_slash_slash_create
    pth = "//ahost/a/b/c"
    u = Alt::URI.create(:netpath => pth)
    assert_kind_of(Alt::URI::Base,u)
    assert_equal(pth,u.netpath)
    assert_equal("ahost",u.host)
    assert_equal("/a/b/c",u.path)
  end

end
