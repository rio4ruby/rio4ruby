#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'
require 'open-uri'
require 'ftp/testdef'

class TC_ftp_anon_write < Test::RIO::TestCase
  @@once = false
  include Test::RIO::FTP::Const
  #FTPROOT = rio('ftp://localhost/')
  #FTPRW = FTPROOT/'riotest/rw'

  SRCDIR = rio('src/')
  DSTDIR = rio('dst/')
  LOCENTS = [rio('f0'),d0=rio('d0'),d0/'f1',d1=d0/'d1',d1/'f2']
  ALLENTS = [FTP_RWROOT/'f0',d0=FTP_RWROOT/'d0',d0/'f1',d1=d0/'d1',d1/'f2']
  def self.once
    @@once = true
    dir = rio(SRCDIR).delete!
    dir < rio(FS_ROROOT)
  end
  def setup
    super
    self.class.once unless @@once
    ALLENTS.reverse.each do |ent|
      if ent.filename =~ /f/
        ent.rm
      else
        ent.rmdir
      end
    end
    #FS_RWROOT.entries { |ent| ent.delete! }
  end
  def test_cp_file_to_dir
    fname = 'f0'
    loc = SRCDIR/fname
    rem = FTP_RWROOT.dup
    rem < loc
    frem = rem/fname
    assert_equal(loc.chomp[],frem.chomp[])
  end
  def test_cp_file_to_file
    fname = 'f0'
    loc = SRCDIR/fname
    rem = FTP_RWROOT.dup/fname
    rem < loc
    assert_equal(loc.chomp[],rem.chomp[])
  end
  def test_cp_dir_left
    #$trace_states = true
    dname = 'd0/'
    loc = SRCDIR/dname
    rem = FTP_RWROOT.dup
    rem < loc
    rpath =  FTP_RWROOT/dname
    lpath = loc
    ans =  rpath[].map{|el| el.rel(FTP_RWROOT)}
    exp =  lpath[].map{|el| el.rel(SRCDIR.abs)}
    assert_equal(exp,ans)
  end
  def test_cp_dir_right
    dname = 'd0'
    loc = SRCDIR/dname
    rem = FTP_RWROOT.dup
    loc > rem
    rpath =  FTP_RWROOT/dname
    lpath = loc
    ans =  rpath[].map{|el| el.rel(FTP_RWROOT)}
    exp =  lpath[].map{|el| el.rel(SRCDIR.abs)}
    assert_equal(exp,ans)
  end


end
