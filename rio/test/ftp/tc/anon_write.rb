require 'rio'
require 'ftp/testdef'


module RIO::FTP::UnitTest
  module AnonWrite
    module Tests
      include Test::RIO::FTP::Const
      
      SRCDIR = rio('src/')
      DSTDIR = rio('dst/')
      LOCENTS = [rio('f0'),d0=rio('d0'),d0/'f1',d1=d0/'d1',d1/'f2']
      ALLENTS = [FTP_RWROOT/'f0',d0=FTP_RWROOT/'d0',d0/'f1',d1=d0/'d1',d1/'f2']
      def setup
        rio(SRCDIR).delete!.mkdir.chdir do 
          rio('f0').touch
          rio('d0').mkdir.chdir do |d|
            rio('f1').touch
            rio('d1').mkdir
          end
        end
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
    
  end
end

