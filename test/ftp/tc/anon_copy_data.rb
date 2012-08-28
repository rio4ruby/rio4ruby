require 'rio'
require 'ftp/testdef'


module RIO::FTP::UnitTest
  module AnonCopyData
    module Tests
      include Test::RIO::FTP::Const
      def test_copy_string
        exp = "a string\n"
        ario = rio(FTP_RWROOT,'file0') < exp
        assert(ario.file?)
        assert_equal(exp.size,ario.size)
        #assert_equal(exp,ario.contents)
      end
      def test_copy_array
        exp = (0..1).map{|n| "Line #{n}\n"}
        # expsz = exp.inject(0) {|sum,el| sum + el.size }
        expsz = exp.join.size
        ario = rio(FTP_RWROOT,'file1') < exp
        assert(ario.file?)
        assert_equal(expsz,ario.size)
        #assert_equal(exp,ario[])
      end


    end
    
  end
end

