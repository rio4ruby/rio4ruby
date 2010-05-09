#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
p Dir.getwd
p $:[0]
require "test/unit"
require 'rio/alturi'

module Alt::URI::UnitTest
  module Create
    module Tests
      def test_starts_with_slash_slash_create
        pth = "//ahost/a/b/c"
        u = Alt::URI.create(:netpath => pth)
        assert_kind_of(Alt::URI::Base,u)
        assert_equal(pth,u.netpath)
        assert_equal("ahost",u.host)
        assert_equal("/a/b/c",u.path)
      end
    end
  end
end

require 'riotest/util'

module Alt::URI::UnitTest
  extend RioTest::Util
  build_mod_testcase_class(:Create)
end


