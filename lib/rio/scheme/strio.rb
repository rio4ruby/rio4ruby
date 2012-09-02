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


require 'rio/rrl/ioi'
require 'stringio'
require 'rio/stream'
require 'rio/stream/open'

module RIO
  module StrIO #:nodoc: all
    RESET_STATE = 'StrIO::Stream::Open'

    class RRL < ::RIO::RRL::IOIBase 
      RIOSCHEME = 'strio'
      RIOPATH = RIO::RRL::CHMAP.invert[RIOSCHEME].to_s.freeze
      attr_accessor :str
      def initialize(u,str="")
        #p "StrIO::RRL initialize: u=#{u.inspect} str=#{str.inspect}"
        alturi = ::Alt::URI.parse(u.to_s)
        super(alturi)
        self.query ||= str
        @sio = self.query
      end
      def self.parse(*a)
        u = a.shift.sub(/^rio:/,'')
        new(u,*a)
      end
      def query=(arg)
        uri.query = if arg.nil?
                      nil 
                    else
                      @sio = (::StringIO === arg ? arg : ::StringIO.new(arg))
                      sprintf('0x%08x',@sio.object_id)
                    end
        arg
      end
      def query
        uri.query.nil? ? nil :  ObjectSpace._id2ref(uri.query.hex)
      end
      alias :stringio :query
      alias :stringio= :query=
      def open(m,*args)
        #p "STRIO open: m=#{m} args=#{args.inspect}"
        strio = self.stringio
        str = strio.string
        nstrio = self.stringio.reopen(str,m.to_s)
        super(nstrio)
      end
    end
    module Stream
      module Ops
        def string() ioh.string end
        def string=(p1) ioh.string = p1 end
      end
      class Open < RIO::Stream::Open
        def string=(p1) rl.query = p1 end
        def stringio() rl.query end
        def string() stringio.string end
        def stream_state(*args) super.extend(Ops) end
      end
    end
  end
end
__END__
