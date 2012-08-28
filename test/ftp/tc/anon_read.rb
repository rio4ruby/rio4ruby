require 'rio'
require 'ftp/testdef'


module RIO::FTP::UnitTest
  module AnonRead
    module Tests
      include Test::RIO::FTP::Const

      FTPRO = FTPROOT/'riotest/ro'
      LOCENTS = [rio('f0'),d0=rio('d0'),d0/'f1',d1=d0/'d1',d1/'f2']
      ALLENTS = [FTP_ROROOT/'f0',d0=FTP_ROROOT/'d0',d0/'f1',d1=d0/'d1',d1/'f2']

      def test_read_file
        f0 = FTP_ROROOT/'f0'
        exp = ""
        open(f0.to_s) { |fh| exp  = fh.gets(nil) }
        ans = rio(f0).contents
        assert_equal(exp,ans)
      end
      def test_read_dir
        ro = FTP_ROROOT.dup
        exp = [ro/'f0',ro/'d0']
        ans = rio(ro).to_a
        assert_equal(exp.sort,ans.sort)
      end
      def test_read_dir_all
        ro = FTP_ROROOT.dup
        exp = ALLENTS
        ans = rio(ro).all[]
        assert_equal(exp.sort,ans.sort)
      end
      def test_read_dir_all_selected_by_name
        ro = FTP_ROROOT.dup
        exp = ALLENTS.select{ |f| f =~ /1$/ }
        ans = ro.all['*1']
        assert_equal(exp.sort,ans.sort)
      end
      def test_read_dir_all_files
        ro = FTP_ROROOT.dup
        exp = ALLENTS.select{ |f| f.file? }
        ans = ro.all.files
        assert_equal(exp.sort,ans.sort)
      end
      def test_read_dir_all_dirs
        exp = ALLENTS.select{ |f| f.dir? }
        ans = FTP_ROROOT.dup.all.dirs
        assert_equal(exp.sort,ans.sort)
      end
      def test_cpfrom_file
        rem = FTP_ROROOT/'f0'
        #$trace_states = true
        loc = rio('f0').delete
        #$trace_states = false
        loc < rem
        #$trace_states = true
        assert_equal(loc.contents,rem.contents)
        #$trace_states = false
        loc = rio('f0').delete
        rem > loc
        assert_equal(loc.contents,rem.contents)
      end
      def test_cpfrom_dir
        rem = FTP_ROROOT/'d0'

        loc = rio('d0').delete!
        loc < rem
        exp = LOCENTS.select{ |f| f =~ %r{d0/} } - [loc]
        ans = loc.dup.all[]
        assert_equal(exp.sort,ans.sort)

        loc = rio('d0').delete!
        rem > loc
        exp = LOCENTS.select{ |f| f =~ %r{d0/} } - [loc]
        ans = loc.dup.all[]
        assert_equal(exp.sort,ans.sort)
      end
      def test_cpfrom_dir_select
        rem = FTP_ROROOT/'d0'

        loc = rio('d0').delete!
        loc < rem.entries('*1')
        exp = LOCENTS.select{ |f| f =~ /1$/ }
        ans = loc.dup.all[]
        assert_equal(exp.sort,ans.sort)

        loc = rio('d0').delete!
        rem.entries('*1') > loc
        exp = LOCENTS.select{ |f| f =~ /1$/ }
        ans = loc.dup.all[]
        assert_equal(exp.sort,ans.sort)
      end


    end
    
  end
end

