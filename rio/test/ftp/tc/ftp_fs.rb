require 'rio'
require 'ftp/testdef'
require "test/unit"


module RIO::FTP::UnitTest
  module FTPFS
    module Tests
      include Test::RIO::FTP::Const
      def assert!(a,msg="negative assertion")
        assert((!(a)),msg)
      end


      def test_initialize
        ustr = 'ftp://frenzy/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal(u,fs.uri)
      end

      def test_create
        ustr = 'ftp://frenzy/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.create(u)
        assert_equal(u,fs.uri)
      end

      def test_anon_remote_root
        ustr = 'ftp://frenzy/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal("/",fs.remote_root)
      end

      def test_user_remote_root
        ustr = 'ftp://riotest:riotest@localhost/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal("/home/riotest/",fs.remote_root)
      end


      def test_user_pwd
        ustr = 'ftp://riotest:riotest@localhost/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal('/home/riotest',fs.pwd)
      end

      def test_anon_pwd
        ustr = 'ftp://frenzy/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal('/',fs.pwd)
      end

      def test_user_getwd
        ustr = 'ftp://riotest:riotest@localhost/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal('/home/riotest',fs.getwd)
      end

      def test_anon_getwd
        ustr = 'ftp://frenzy/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal('/',fs.getwd)
      end

      def test_anon_root
        ustr = 'ftp://frenzy/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal('ftp://frenzy/',fs.root)
      end

      def test_user_root
        ustr = 'ftp://riotest:riotest@localhost/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal('ftp://riotest@localhost/',fs.root)
      end

      def test_user_cwd
        ustr = 'ftp://riotest:riotest@localhost/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal('ftp://riotest@localhost/',fs.cwd)
      end

      def test_anon_cwd
        ustr = 'ftp://frenzy/riotest/ro/'
        u = Alt::URI.parse(ustr)
        fs = RIO::FTP::FS.new(u)
        assert_equal('ftp://frenzy/',fs.cwd)
      end


      def test_anon_remote_path
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        pth = 'riotest/ro'
        rpth = fs.remote_path(pth)
        #p "ustr=#{ustr} fs.remote_path(#{pth})=#{fs.remote_path(pth)}"
        assert_equal("/riotest/ro",fs.remote_path(pth))
      end

      def test_anon_root_remote_path
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        pth = '/riotest/ro'
        rpth = fs.remote_path(pth)
        #p "ustr=#{ustr} fs.remote_path(#{pth})=#{fs.remote_path(pth)}"
        assert_equal("/riotest/ro",rpth)
      end

      def test_user_remote_path
        ustr = 'ftp://riotest:riotest@localhost/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        pth = 'riotest/ro'
        rpth = fs.remote_path(pth)
        #p "ustr=#{ustr} fs.remote_path(#{pth})=#{fs.remote_path(pth)}"

        assert_equal("/home/riotest/riotest/ro",fs.remote_path('riotest/ro'))
      end

      def test_user_root_remote_path
        ustr = 'ftp://riotest:riotest@localhost/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        pth = '/riotest/ro'
        rpth = fs.remote_path(pth)
        #p "ustr=#{ustr} fs.remote_path(#{pth})=#{fs.remote_path(pth)}"

        assert_equal("/riotest/ro",fs.remote_path(pth))
      end

      def test_anon_chdir
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        fs.chdir('riotest/ro/')
        assert_equal("/riotest/ro",fs.getwd)
        fs.chdir(fs.remote_root)
      end

      def test_anon_root_chdir
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        fs.chdir('/riotest/ro/')
        assert_equal("/riotest/ro",fs.getwd)
        fs.chdir(fs.remote_root)
      end

      def test_user_chdir
        ustr = 'ftp://riotest:riotest@localhost/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        fs.chdir('home/riotest/')
        assert_equal("/home/riotest/home/riotest",fs.getwd)
        fs.chdir(fs.remote_root)
      end

      def test_user_root_chdir
        ustr = 'ftp://riotest:riotest@localhost/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        fs.chdir('/home/riotest/')
        assert_equal("/home/riotest",fs.getwd)
        fs.chdir(fs.remote_root)
      end

      def test_anon_mkdir
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        rwdir = 'riotest/rw/'
        newdir = rwdir + 'anonmd1'
        fs.mkdir(newdir)
        assert(fs.directory?(newdir))
        fs.rmdir(newdir)
      end

      def test_user_mkdir
        ustr = 'ftp://riotest:riotest@localhost/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        rwdir = 'riotest/rw/'
        newdir = rwdir + 'usermd1'
        fs.mkdir(newdir)
        assert(fs.directory?(newdir))
        fs.rmdir(newdir)
      end

      def test_anon_mkpath
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        rwdir = 'riotest/rw/'
        newdir1 = rwdir + 'anonmp1'
        newdir2 = newdir1 + '/anonmp2'
        fs.mkpath(newdir2)
        assert(fs.directory?(newdir2))
        fs.rmdir(newdir2)
        fs.rmdir(newdir1)
      end

      def test_anon_chdir_remote_path
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        dpth = 'riotest/ro'
        fs.chdir(dpth)
        pth = 'd0'
        rpth = fs.remote_path(pth)
        # p "ustr=#{ustr} fs.remote_path(#{pth})=#{fs.remote_path(pth)}"
        assert_equal("/riotest/ro/d0",fs.remote_path(pth))
        fs.chdir(fs.remote_root)
      end


      def test_anon_block_chdir
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        assert_equal(fs.remote_root,fs.remote_wd)
        dstr = 'riotest/ro/'
        dwd = fs.remote_root + dstr
        fs.chdir(dstr) do |d|
          assert_equal(dwd,d)
          assert_equal(dwd,fs.remote_wd)
        end
        assert_equal(fs.remote_root,fs.remote_wd)
      end

      def test_anon_rmtree
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        rwdir = 'riotest/rw/'
        fs.chdir(rwdir) do 
          newdir1 = 'anonrt1'
          newdir2 = newdir1 + '/anonrt2'
          fs.mkdir(newdir1)
          fs.mkdir(newdir2)
          assert(fs.directory?(newdir2))
          fs.rmtree(newdir1)
          assert!(fs.exist?(newdir2))
          assert!(fs.exist?(newdir1))
        end
        #fs.chdir(fs.remote_root)
      end

      def test_anon_root_mkpath
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        rwdir = '/riotest/rw/'
        newdir1 = rwdir + 'anonmp1'
        newdir2 = newdir1 + '/anonmp2'
        fs.mkpath(newdir2)
        assert(fs.directory?(newdir2))
        fs.rmdir(newdir2)
        fs.rmdir(newdir1)
      end

      def test_user_root_mkpath
        ustr = 'ftp://riotest:riotest@localhost/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        rwdir = '/home/riotest/riotest/rw/'
        newdir1 = rwdir + 'usermp1'
        newdir2 = newdir1 + '/usermp2'
        fs.mkpath(newdir2)
        assert(fs.directory?(newdir2))
        fs.rmdir(newdir2)
        fs.rmdir(newdir1)
      end

      def test_anon_put
        fname = 'anon_put.txt'
        fcont = "ftp_anon_put"
        rio(fname).puts!(fcont)
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        rwdir = 'riotest/rw/'
        fs.chdir(rwdir) do
          begin
            fs.put(fname)
            assert(fs.file?(fname))
          ensure
            fs.rm(fname)
          end
        end
      end

      def test_anon_size
        fname = 'anon_size.txt'
        fcont = "ftp_anon_put"
        locfile = rio(fname).puts!(fcont)
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        rwdir = 'riotest/rw/'
        fs.chdir(rwdir) do
          begin
            fs.put(fname)
            assert_equal(locfile.size,fs.size(fname))
          ensure
            fs.rm(fname)
          end
        end
      end

      def test_anon_mv
        fname = 'anon_put.txt'
        cname = 'copy_anon_put.txt'
        fcont = "ftp_anon_put"
        rio(fname).puts!(fcont)
        ustr = 'ftp://frenzy/'
        fs = RIO::FTP::FS.new(Alt::URI.parse(ustr))
        rwdir = 'riotest/rw/'
        fs.chdir(rwdir) do
          begin
            fs.put(fname)
            assert(fs.file?(fname))
            sz = fs.size(fname)
            fs.mv(fname,cname)
            assert!(fs.exist?(fname))
            assert(fs.file?(cname))
            assert_equal(sz,fs.size(cname))
          ensure
            fs.rm(cname)
          end
        end
      end



    end
    
  end
end

