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

require 'rio/stream'
require 'rio/stream/open'
require 'rio/fibpipe'
require 'rio/rrl/ioi'
require 'rio/rrl/chmap'



module RIO
  module CmdIO #:nodoc: all
     RESET_STATE = 'Stream::Duplex::Open'

    class RRL < RRL::SysIOBase 
      RIOSCHEME = 'cmdio'
      RIOPATH = RIO::RRL::CHMAP.invert[RIOSCHEME].to_s.freeze
      
      attr_reader :ior,:iow
      def initialize(u,*a)
        super(u)
        a = a.map(&:to_s)
        com = case c = a.shift
              when self.class then c.cmd
              else c
              end
        unless com.nil?
          self.path = com
          self.query = a
        end
      end
      extend RIO::Fwd
      fwd :uri, :path
      def query
        uri.query
      end
      def query=(args)
        uri.query = args
      end
      def self.parse(*a)
        u = a.shift.sub(/^rio:/,'')
        new(u,*a)
      end
      alias :cmd :path
      alias :args :query
      def fib_proc(m)
        poargs = args.nil? ? cmd : [cmd,args]
        if m.allows_write?
          Cmd::FibPipeProc.new(poargs,m.to_s)
        else
          Cmd::FibSourceProc.new(poargs,m.to_s)
        end
      end

      def to_s()
        [cmd,args].flatten.join(' ').strip
      end
      def open(m)
        poarg = args.nil? ? cmd : [cmd,args].flatten
        io = IO.popen(poarg,m.to_s)
        super(io)
      end


    end
  end
  module Stream
    module Duplex
      class Open < RIO::Stream::Open
        include Piper::Cp::Input
        
        def cmd() rl.path end
        def cmd_args() rl.query end
      end
    end
  end
end
