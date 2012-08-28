require 'rio'
require 'ftp/testdef'


module RIO::FTP::UnitTest
  module Copy
    module Tests
      include Test::RIO::FTP::Const

      def test_cp_http2ftp
        http_url = 'http://localhost/riotest/lines.txt.gz'
        ftp_url = 'ftp://localhost/riotest/rw/lines.txt.gz'
        rio(ftp_url).rm
        assert(!rio(ftp_url).exist?)
        rio(ftp_url) < rio(http_url)
        assert(rio(ftp_url).exist?)
      end

      def test_cp_gunzip_http2ftp
        http_url = 'http://localhost/riotest/lines.txt.gz'
        ftp_url = 'ftp://localhost/riotest/rw/lines.txt'
        rio(ftp_url).rm
        assert(!rio(ftp_url).exist?)
        rio(http_url).gzip.lines(3,7,9) > rio(ftp_url)
        # exp = rio(http_url).gzip.chomp.lines[3,7,9]
        exp = ['Line 3','Line 7','Line 9']
        ans = rio(ftp_url).chomp[]
        assert_equal(exp,ans)
      end

    end
    
  end
end

