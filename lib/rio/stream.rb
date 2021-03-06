#--
# ===========================================================================
# Copyright (c) 2005-2017 Christopher Kleckner
# All rights reserved
#
# This file is part of the Rio library for ruby.
#
# Rio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Rio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rio; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# =========================================================================== 
#++
#


require 'rio/stream/base'
module RIO
  autoload :Ops, 'rio/ops'
  module Stream
    autoload :Open, 'rio/stream/open'
    autoload :Duplex, 'rio/stream/duplex'
  end
end
require 'rio/filter'
require 'rio/ops/path'
require 'rio/ops/stream'
require 'rio/ops/stream/input'
require 'rio/ops/stream/output'
require 'rio/ext'
require 'rio/filter/gzip'

module RIO

  module Stream #:nodoc: all
    class Reset < Base
      # Mixin the appropriate ops
      include Ops::Stream::Reset

      def check?() true end
      def when_missing(sym,*args) retryreset() end
    end

    class IOBase < Base
      # Mixin the appropriate ops
      include Ops::Path::Str
      include Ops::Stream::Status
      include Ops::Stream::Manip

      
      def check?() open? end
      def when_missing(sym,*args) 
        #p callstr('when_missing',sym,*args)
        retryreset() 
      end
      def base_state() 'Stream::Close' end
      def reset()
        self.close.softreset()
      end
      def setup
        ioh.sync = sync? if cx.has_key?('sync')

        ioh.set_encoding(*enc?) if cx.has_key?(:enc_args)
        self
      end
      def add_filter(mod)
        unless ioh.kind_of?(mod)
          ioh.extend(mod)
        end
      end
      def rectype_mod
        case cx['stream_rectype']
        when 'lines' then RIO::RecType::Lines
        when 'bytes' then RIO::RecType::Bytes
        else RIO::RecType::Lines
        end
      end
      def self.copier(src,dst)
        RIO::Copy::Strategy::Stream.instance.copier(src,dst)
      end
    end
    module Ini
      def setup
        super
        @recno = -1
        @get_selrej,@get_rangetops = create_selrej()
        self
      end
    end
    class Input < IOBase
      include Ops::Stream::Input
      include Ini
      include Filters

      def add_extensions()
        #p callstr('add_extensions')
        Ext::Input.add_extensions(self)
      end
      def add_filters
        if gzip?
          gz = Zlib::GzipReader.new(self.ioh.ios)
          gz.extend Filter::GZipMissing
          gz.extend Filter::GZipWin32MissingEachLine
          self.ioh.ios = gz
          add_filter(Filter::GZipRead)
        end
        if csv?
          require 'rio/ext/csv/filter' if $USE_FASTER_CSV
          self.extend(::RIO::Ext::CSV::Input)
          add_csv_filter() if $USE_FASTER_CSV
        end
        add_line_filters()
        self
      end
      def add_rec_methods()
        self.extend(rectype_mod.module_eval('Input'))
      end
    end 

    class Output < IOBase
      include Ops::Stream::Output
      
      def add_rec_methods()
        self.extend(rectype_mod.module_eval('Output'))
      end
      def add_extensions()
        Ext::Output.add_extensions(self)
      end
      def add_filters
        if gzip?
          gz = Zlib::GzipWriter.new(self.ioh.ios)
          gz.extend Filter::GZipMissing
          self.ioh.ios = gz
          add_filter(Filter::GZipWrite)
        end
        if csv?
          require 'rio/ext/csv/filter'  if $USE_FASTER_CSV
          self.extend(::RIO::Ext::CSV::Output)
          add_csv_filter() if $USE_FASTER_CSV
        end
        self
      end

    end 

    class InOut < IOBase
      include Ops::Stream::Input
      include Ops::Stream::Output
      include Ini
      include Filters
      
      def add_rec_methods()
        self.extend(rectype_mod.module_eval('Input'))
        self.extend(rectype_mod.module_eval('Output'))
      end
      def add_extensions()
        Ext::Input.add_extensions(self)
        Ext::Output.add_extensions(self)
      end

      def add_filters
        add_line_filters()
        self
      end

    end 
  end

end # module RIO
