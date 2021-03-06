#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/rio/')
end
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require 'tc/abs2'
require 'tc/yaml'
require 'tc/truncate'
require 'tc/line_record_row'
#require 'tc/path_parts'
#require 'tc/abs'
require 'tc/abs2'
require 'tc/tonl'
require 'tc/files_select'
require 'tc/emptyriodir'
require 'tc/entsel'
require 'tc/base'
require 'tc/base2'
require 'tc/clearsel'
require 'tc/closeoncopy'
require 'tc/closeoneof'
#require 'tc/cmdpipe' unless $mswin32 || $jruby
require 'tc/copy'
require 'tc/copy-from'
require 'tc/copy-to'
require 'tc/copyarray'
require 'tc/copydest'
require 'tc/copydir'
require 'tc/copy-dir-samevar'
require 'tc/copydirlines'
require 'tc/copylines'
require 'tc/create'
#require 'tc/csv'
#require 'tc/csv2'
#require 'tc/csv_columns'
#require 'tc/csv_gzip'
#require 'tc/csv_headers'
require 'tc/dir'
require 'tc/dir_iter'
require 'tc/dirent'
require 'tc/each'
require 'tc/each_break'
require 'tc/empty'
require 'tc/entary'
require 'tc/eq'
require 'tc/expand_path'
require 'tc/ext'
require 'tc/get'
require 'tc/gzip'
require 'tc/getrec'
require 'tc/io_each_byte'
require 'tc/io_read'
require 'tc/iometh'
require 'tc/likeio'
require 'tc/lines'
require 'tc/clone'
require 'tc/misc'
require 'tc/nolines'
require 'tc/noqae'
require 'tc/null' unless $mswin32
require 'tc/overload'
require 'tc/pa'
require 'tc/paths'
require 'tc/pid'
#require 'tc/piper' unless $mswin32 || $jruby
require 'tc/qae'
require 'tc/qae_riovar'
require 'tc/readline'
require 'tc/records'
require 'tc/rename'
#require 'tc/riorl'
require 'tc/route'
require 'tc/selnosel'
require 'tc/skip'
require 'tc/skiplines'
require 'tc/split'
require 'tc/splitpath'
require 'tc/splitlines'
require 'tc/symlink' unless $mswin32 || $jruby
require 'tc/symlink0' unless $mswin32 || $jruby
require 'tc/symlink1' unless $mswin32 || $jruby
#require 'tc/temp'
#require 'tc/tempdir'
#require 'tc/tempfile'

module RIO
  module TC
    class TestSuite
      def self.suite
        suite = Test::Unit::TestSuite.new("RIO::TC::TestSuite")
        suite << TC_RIO_abs2.suite
        suite << TC_yaml.suite
        suite << TC_truncate.suite
        suite << TC_line_record_row.suite
        return suite
      end
    end
  end
end


Test::Unit::UI::Console::TestRunner.run(RIO::TC::TestSuite)  if $0 == __FILE__



