require 'rio'
require 'ftp/testdef'


module RIO::FTP::UnitTest
  module FTP2FTP
    module Tests
      include Test::RIO::FTP::Const

      def test_cp_ro2rw_file1
        fname = 'f0'
        src = FTP_ROROOT/fname
        dst = FTP_RWROOT/fname
        dst < src
        assert_equal(src.chomp[],dst.chomp[])
      end
      def test_cp_ro2rw_file2
        fname = 'f0'
        src = FTP_ROROOT/fname
        dst = FTP_RWROOT
        dst < src
        fdst = dst/fname
        assert_equal(src.chomp[],fdst.chomp[])
      end

      def smap(a) a.map(&:to_s) end
      def test_cp_ro2rw_dir
        fname = 'd0'
        src = FTP_ROROOT/fname
        dst = FTP_RWROOT
        dst < src
        ans = rio(FTP_RWROOT,fname).to_a
        exp = rio(FTP_ROROOT,fname).to_a.map{ |s| s.sub('ro','rw') }
        
        assert_equal(smap(exp),smap(ans))
      end

    end
    
  end
end

