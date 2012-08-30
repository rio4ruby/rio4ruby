#--
# ===========================================================================
# Copyright (c) 2005-2012 Christopher Kleckner
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
#
# ==== Rio - Ruby I/O Facilitator
#
# Rio is a facade for most of the standard ruby classes that deal with
# I/O; providing a simple, intuitive, succinct interface to the
# functionality provided by IO, File, Dir, Pathname, FileUtils,
# Tempfile, StringIO, OpenURI and others. Rio also provides an
# application level interface which allows many common I/O idioms to be
# expressed succinctly.
#
# ===== Suggested Reading
#
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Doc::EXAMPLES
# * RIO::Rio
#
# Project::       http://rubyforge.org/projects/rio/
# Documentation:: http://rio4ruby.com/
# Bugs::          http://rubyforge.org/tracker/?group_id=821
# Blog::          http://rio4ruby.blogspot.com/
# Email::         rio4ruby@rubyforge.org
#


#require 'rio/stream'
#require 'rio/stream/duplex'

module RIO
  module Stream
    module Duplex
      module Ops
        module Output
          def wclose()
            p "wclose #{self}"
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
        extend Forwardable
        extend RIO::Fwd
        def base_state() 'Stream::Duplex::Close' end
        #def ior() fibproc.pipe.rd end
        #def iow() fibproc.pipe.wr end
        def ior() ioh() end
        def iow() ioh end
      end

      class Open < RIO::Stream::Open
        fwd :data,:fibproc
        include Ops
        def output() stream_state('Stream::Duplex::Output') end
        def input()  stream_state('Stream::Duplex::Input')  end
        def inout()  stream_state('Stream::Duplex::InOut')  end
        #def fibproc() input.fibproc() end
        protected

        def open_(*args)
          #p callstr('open_',args.inspect)+" mode='#{mode?}' (#{mode?.class}) ioh=#{self.ioh} open?=#{open?}"
          self.ioh = self.rl.open(mode?,*args) unless open?
          #p data
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
        #include Ops::Output
      end
      
      class InOut < RIO::Stream::InOut
        include Ops
        fwd :data,:fibproc
        def base_state() 'Stream::Duplex::Close' end
        #include Ops::Output
        #include Ops::Input
        def get()
          until self.eof?
            raw_rec = self._get_rec
            return to_rec_(raw_rec) if @get_selrej.match?(raw_rec,@recno)
          end
          #loop do
          #  raw_rec = self._get_rec
          #  return to_rec_(raw_rec) if @get_selrej.match?(raw_rec,@recno)
          #  break if self.eof?
          #end
          self.close if closeoneof?
          nil
#          (closeoneof? ? self.on_eof_close{ nil } : nil)
        end

      end
      class Close < RIO::Stream::Close
      end
      class Reset < RIO::Stream::Reset
      end
    end
  end
end
