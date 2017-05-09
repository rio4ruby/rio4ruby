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


#require 'rio/stream'
#require 'rio/stream/duplex'

module RIO
  module Stream
    module Duplex
      module Ops
        module Output
          def wclose()
            ioh.close_write
            return self.close.softreset if ioh.closed?
            self
          end
        end
      end
    end
  end
end


module RIO
  module Stream
    module Duplex
      module Ops
        extend RIO::Fwd
        def base_state() 'Stream::Duplex::Close' end
        def ior() ioh() end
        def iow() ioh end
      end

      class Open < RIO::Stream::Open
        fwd :data,:fibproc
        include Ops
        def output() stream_state('Stream::Duplex::Output') end
        def input()  stream_state('Stream::Duplex::Input')  end
        def inout()  stream_state('Stream::Duplex::InOut')  end
        protected

        def open_(*args)
          #p callstr('open_',args.inspect)+" mode='#{mode?}' (#{mode?.class}) ioh=#{self.ioh} open?=#{open?}"
          self.ioh = self.rl.open(mode?,*args) unless open?
          self
        end
      end

      class Input < RIO::Stream::Input
        include Ops
        fwd :data,:fibproc
      end

      class Output < RIO::Stream::Output
        include Ops
        fwd :data,:fibproc
        def base_state() 'Stream::Duplex::Close' end
      end
      
      class InOut < RIO::Stream::InOut
        include Ops
        fwd :data,:fibproc
        def base_state() 'Stream::Duplex::Close' end
        def get()
          until self.eof?
            raw_rec = self._get_rec
            return to_rec_(raw_rec) if @get_selrej.match?(raw_rec,@recno)
          end
          self.close if closeoneof?
          nil
        end

      end
      class Close < RIO::Stream::Close
      end
      class Reset < RIO::Stream::Reset
      end
    end
  end
end
