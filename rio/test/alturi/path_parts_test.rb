#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/rio/')
end
require "test/unit"
require 'alturi'

class Alt::URI::PathPartsTest < Test::Unit::TestCase
  
  def setup
    super
  end
  
  def teardown
    super
  end

  def test_rel_dirname
    u = Alt::URI.create(:path => 'a/b/c.txt')
    assert_equal("a/b",u.dirname)
  end
  def test_rel_basename
    u = Alt::URI.create(:path => 'a/b/c.txt')
    assert_equal("c",u.basename)
  end
  def test_rel_endslash_basename
    u = Alt::URI.create(:path => 'a/b/c/')
    assert_equal("c",u.basename)
  end
  def test_rel_dirname=
    u = Alt::URI.create(:path => 'a/b/c.txt')
    u.dirname= 'd/f/'
    assert_equal("d/f/c.txt",u.to_s)
  end
  def test_rel_abs_dirname=
    u = Alt::URI.create(:path => 'a/b/c.txt')
    rtn = (u.dirname= '/d/f/')
    assert_equal("/d/f/c.txt",u.to_s)
    assert_equal('/d/f/',rtn)
  end
  def test_rel_nodir_dirname
    u = Alt::URI.create(:path => 'a')
    assert_equal(".",u.dirname)
  end
  def test_rel_nodir_dirname=
    u = Alt::URI.create(:path => 'a')
    rtn = (u.dirname = 'f/')
    assert_equal("f/a",u.to_s)
    assert_equal("f/",rtn)
  end
  def test_rel_nodir_drive_dirname=
    u = Alt::URI.create(:path => 'a')
    rtn = (u.dirname = 'D:/')
    assert_equal("D:/a",u.to_s)
    assert_equal("D:/",rtn)
  end
  def test_rel_nodir2_dirname=
    u = Alt::URI.create(:path => 'a')
    rtn = (u.dirname = 'f')
    assert_equal("f/a",u.to_s)
    assert_equal("f",rtn)
  end
  def test_root_path_only_dirname
    u = Alt::URI.create(:path => '/a/b/c.txt')
    assert_equal("/a/b",u.dirname)
  end
  def test_emptypath_dirname
    u = Alt::URI.create(:path => "")
    assert_equal(".",u.dirname)
  end
  def test_rootpath_dirname
    u = Alt::URI.create(:path => "/")
    assert_equal("/",u.dirname)
  end
  def test_drive_dirname
    u = Alt::URI.create(:path => "C:/My Documents/afile.txt")
    assert_equal("C:/My Documents",u.dirname)
  end
  def test_drive_root_dirname
    u = Alt::URI.create(:path => "C:/")
    assert_equal("C:/",u.dirname)
  end


  def test_rel_basename
    u = Alt::URI.create(:path => 'a/b/c.txt')
    assert_equal("c",u.basename)
  end
  def test_rel_basename=
    u = Alt::URI.create(:path => 'a/b/c.txt')
    rtn = (u.basename = 'zip')
    assert_equal("a/b/zip.txt",u.to_s)
    assert_equal("zip",rtn)
  end

  def test_rel_extname
    u = Alt::URI.create(:path => 'a/b/c.txt')
    assert_equal(".txt",u.extname)
  end
  def test_rel_extname=
    u = Alt::URI.create(:path => 'a/b/c.txt')
    rtn = (u.extname = '.zip')
    assert_equal("a/b/c.zip",u.to_s)
    assert_equal(".zip",rtn)
  end




  def test_rel_nodir_filename
    u = Alt::URI.create(:path => 'a')
    assert_equal("a",u.filename)
  end
  def test_rel_nodir_filename=
    u = Alt::URI.create(:path => 'a')
    rtn = (u.filename = 'b')
    assert_equal("b",u.to_s)
    assert_equal("b",rtn)
  end

  def test_root_path_only_filename
    u = Alt::URI.create(:path => '/a/b/c.txt')
    assert_equal("c.txt",u.filename)
  end


  def test_rel_filename
    u = Alt::URI.create(:path => 'a/b/c.txt')
    assert_equal("c.txt",u.filename)
  end
  def test_rel_filename=
    u = Alt::URI.create(:path => 'a/b/c.txt')
    rtn = (u.filename = 'z.txt')
    assert_equal("a/b/z.txt",u.to_s)
    assert_equal("z.txt",rtn)
  end
  def test_rel_filename=
    u = Alt::URI.create(:path => '/a/b/c.txt')
    rtn = (u.filename = 'z.txt')
    assert_equal("/a/b/z.txt",u.to_s)
    assert_equal("z.txt",rtn)
  end
  def test_rel_end_with_slash_filename=
    u = Alt::URI.create(:path => 'a/b/')
    rtn = (u.filename = 'z.txt')
    assert_equal("a/z.txt/",u.to_s)
    assert_equal("z.txt",rtn)
  end
  def test_root_end_with_slash_filename=
    u = Alt::URI.create(:path => '/a/b/')
    rtn = (u.filename = 'z.txt')
    assert_equal("/a/z.txt/",u.to_s)
    assert_equal("z.txt",rtn)
  end

  def test_rel_end_with_slash2_filename=
    u = Alt::URI.create(:path => 'a/b/')
    rtn = (u.filename = 'c/')
    assert_equal("a/c/",u.to_s)
    assert_equal("c/",rtn)
  end
  def test_root_end_with_slash2_filename=
    u = Alt::URI.create(:path => '/a/b/')
    rtn = (u.filename = 'c/')
    assert_equal("/a/c/",u.to_s)
    assert_equal("c/",rtn)
  end
  def test_rel_end_with_slash_filename
    u = Alt::URI.create(:path => 'a/b/')
    assert_equal("b",u.filename)
  end
  def test_root_end_with_slash_filename
    u = Alt::URI.create(:path => '/a/b/')
    assert_equal("b",u.filename)
  end



  def test_emptypath_filename
    u = Alt::URI.create(:path => "")
    assert_equal("",u.filename)
  end
  def test_emptypath_filename=
    u = Alt::URI.create(:path => "")
    rtn = (u.filename = 'c.txt')
    assert_equal('c.txt',u.to_s)
    assert_equal('c.txt',rtn)
  end
  def test_emptypath_drive_filename=
    u = Alt::URI.create(:path => "")
    rtn = (u.filename = 'C:/c.txt')
    assert_equal('C:/c.txt',u.to_s)
    assert_equal('C:/c.txt',rtn)
  end
  def test_rootpath_filename
    u = Alt::URI.create(:path => "/")
    assert_equal("/",u.filename)
  end
  def test_rootpath_filename=
    u = Alt::URI.create(:path => "/")
    rtn = (u.filename = 'c.txt')
    assert_equal("c.txt",u.to_s)
    assert_equal("c.txt",rtn)
  end

#  def test_path=
#    u = Alt::URI::File.new
#    u.path = '/loc/My Stuff'
#    assert_equal('/loc/My Stuff', u.path)
#    assert_equal('file:///loc/My%20Stuff', u.to_s)

#    u.path = '/loc/other_stuff'
#    assert_equal('/loc/other_stuff', u.path)

#  end


end
