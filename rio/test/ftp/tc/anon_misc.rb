require 'rio'
require 'ftp/testdef'
require 'riotest/util'

module RIO::FTP::UnitTest
  module AnonMisc
    module Tests
      include Test::RIO::FTP::Const
      include RioTest::Util

      ALLENTS = [FTP_RWROOT/'f0',d0=FTP_RWROOT/'d0',d0/'f1',d1=d0/'d1',d1/'f2']

      def test_dir
        #$trace_states = true
        ftproot = rio(FTPROOT)
        ftproot.chdir
        #assert_equal('/',ftproot.getwd)
        #assert_equal(ftproot,ftproot.cwd)

        #rwdir = rio(FTP_RWROOT).chdir
        #assert_equal(FTP_RWROOT,rwdir.cwd)
      end
      def test_mkdir
        rwdir = rio(FTP_RWROOT)
        rio(rwdir,'dir1').rmdir
        rio(rwdir,'dir0').rmdir
        r = rio(rwdir,'dir0')
        r.mkdir
        assert_equal(smap([FTP_RWROOT/'dir0']),smap(FTP_RWROOT.entries[/^dir/]))
      end
      def test_rmdir
        rwdir = rio(FTP_RWROOT)
        rio(rwdir,'dir1').rmdir
        rio(rwdir,'dir0').rmdir
        rio(rwdir,'dir1').mkdir
        assert_equal(smap([FTP_RWROOT/'dir1']),smap(FTP_RWROOT.entries[/^dir/]))
        rio(rwdir,'dir1').rmdir
        assert_equal(smap([]),smap(FTP_RWROOT.entries[/^dir/]))
      end
      def test_rm
        rwdir = rio(FTP_RWROOT)
        locfile = rio('locfile').touch
        locfile > rwdir
        remfile = rwdir/locfile
        assert(remfile.file?)
        remfile.delete
        assert(!remfile.exist?)
      end
      def test_rename_file
        rwdir = rio(FTP_RWROOT)
        locfile = rio('locfile').touch
        locfile > rwdir
        remfile = rwdir/locfile
        assert(remfile.file?)
        remfile_new = rwdir/'remfile'
        remfile.rename(remfile_new)
        assert(remfile_new.file?)
        assert(!remfile.exist?)
      end
      def test_rename_dir
        rwdir = rio(FTP_RWROOT)
        locdir = rio('locdir').mkdir
        locdir > rwdir
        remdir = rwdir/locdir
        assert(remdir.dir?)
        remdir_new = rwdir/'remdir'
        remdir.rename(remdir_new)
        assert(remdir_new.dir?)
        assert(!remdir.exist?)
      end
      def test_test
        file = FTP_ROROOT/'f0'
        assert(file.file?)
        assert(file.exist?)
        assert(!file.dir?)
        dir = FTP_ROROOT/'d0'
        assert(!dir.file?)
        assert(dir.exist?)
        assert(dir.dir?)
        nada = FTP_ROROOT/'nada'
        assert(!nada.file?)
        assert(!nada.exist?)
        assert(!nada.dir?)
      end
      def test_size
        file = FTP_ROROOT/'f0'
        dir = FTP_ROROOT/'d0'
        nada = FTP_ROROOT/'nada'
        assert_equal(6,file.size)
        assert_raise(::Net::FTPPermError) { dir.size }
        assert_raise(::Net::FTPPermError) { nada.size }
      end

      def test_mtime
        file = FTP_ROROOT/'f0'
        dir = FTP_ROROOT/'d0'
        nada = FTP_ROROOT/'nada'
        assert_instance_of(::Time,file.mtime)
        assert_raise(::Net::FTPPermError) { dir.mtime }
        assert_raise(::Net::FTPPermError) { nada.mtime }

      end


    end
    
  end
end

