require 'rio'
require 'ftp/testdef'
require 'lib/assertions'
require 'riotest/util'

module RIO::FTP::UnitTest
  module AnonSpecial
    module Tests
      include Test::RIO::FTP::Const
      include RIOTest::Assertions
      include RioTest::Util
      def test_mkpath
        rwdir = rio(FTP_RWROOT)
        tpath = rwdir/'as_mkpath0'/'as_mkpath1'/'as_mkpath2'
        tpath.mkpath
        assert(tpath.dir?)
      end
      def test_rmtree
        rwdir = rio(FTP_RWROOT)
        tpath = rwdir/'as_rmtree0'/'as_rmtree1'/'as_rmtree2'
        tpath.mkpath
        assert(tpath.dir?)
        rwdir/'as_rmtree0'/'as_rmtree0' < "a file"
        rwdir/'as_rmtree0'/'as_rmtree1'/'as_rmtree1' < "a file"
        d0 = rio(rwdir,'as_rmtree0').rmtree
        assert!(d0.exist?)
        #    tpath.mkpath
        #    assert(tpath.dir?)
        #    d0 = rio(rwdir,'as_rmtree0').rmtree
        #    assert!(d0.exist?)
      end

    end
    
  end
end

