#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/rio/')
end
require "test/unit"
require 'alturi'

class Alt::URI::RFC_Test < Test::Unit::TestCase

  BSTR = "http://a/b/c/d;p?q"
  BASE = ::Alt::URI.parse(BSTR)

  RFC_URIS = [
    ["g:h", "g:h"],
    ["g", "http://a/b/c/g"],
    ["./g", "http://a/b/c/g"],
    ["g/", "http://a/b/c/g/"],
    ["/g", "http://a/g"],
    ["//g", "http://g"],
    ["?y", "http://a/b/c/d;p?y"],
    ["g?y", "http://a/b/c/g?y"],

    ["g#s", "http://a/b/c/g#s"],
    ["g?y#s", "http://a/b/c/g?y#s"],
    [";x", "http://a/b/c/;x"],
    ["g;x", "http://a/b/c/g;x"],
    ["g;x?y#s", "http://a/b/c/g;x?y#s"],
    [".", "http://a/b/c/"],
    ["..", "http://a/b/"],
    ["../", "http://a/b/"],
    ["", "http://a/b/c/d;p?q"],
    ["./", "http://a/b/c/"],
    ["../g", "http://a/b/g"],
    ["../..", "http://a/"],
    ["../../", "http://a/"],
    ["../../g", "http://a/g"],
    ["../../../g", "http://a/g"],
    ["../../../../g", "http://a/g"],

    ["/./g", "http://a/g"],
    ["/../g", "http://a/g"],
    ["g.", "http://a/b/c/g."],
    [".g", "http://a/b/c/.g"],
    ["g..", "http://a/b/c/g.."],
    ["..g", "http://a/b/c/..g"],

    ["./../g", "http://a/b/g"],
    ["./g/.", "http://a/b/c/g/"],
    ["g/./h", "http://a/b/c/g/h"],
    ["g/../h", "http://a/b/c/h"],
    ["g;x=1/./y", "http://a/b/c/g;x=1/y"],
    ["g;x=1/../y", "http://a/b/c/y"],

    ["g?y/./x", "http://a/b/c/g?y/./x"],
    ["g?y/../x", "http://a/b/c/g?y/../x"],
    ["g#s/./x", "http://a/b/c/g#s/./x"],
    ["g#s/../x", "http://a/b/c/g#s/../x"],

    #["http:g", "http:g"], #         ; for strict parsers
  ]

  def test_abs
    (0...RFC_URIS.size).each do |i|
      u = ::Alt::URI.parse(RFC_URIS[i][0])
      ans = u.abs(BASE)
      assert_equal(RFC_URIS[i][1],ans.to_s)
    end
  end

  def test_rel_abs
    (0...RFC_URIS.size).each do |i|
      u = ::Alt::URI.parse(RFC_URIS[i][1])
      ans = u.rel(BASE).abs(BASE)
      assert_equal(RFC_URIS[i][1],ans.to_s)
    end
  end
end
