#--
# =============================================================================== 
# Copyright (c) 2005, Christopher Kleckner
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
# =============================================================================== 
#++
#
# To create the documentation for Rio run the command
#  rake rdoc
# from the distribution directory. Then point your browser at the 'doc/rdoc' directory.
#
# Suggested Reading
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Rio
#
# <b>Rio is pre-alpha software. 
# The documented interface and behavior is subject to change without notice.</b>


require 'rio/rl/ioi'
require 'stringio'
require 'rio/stream'
require 'rio/stream/open'

module RIO
  module StrIO #:nodoc: all
    RESET_STATE = 'StrIO::Stream::Open'

    class RL < RL::IOIBase 
      RIOSCHEME = 'strio'
      RIOPATH = RIO::RL::CHMAP.invert[RIOSCHEME].freeze
      def initialize(str="")
        @str = str
      end
      def open(m,*args)
        ::StringIO.new(@str,m.to_s,*args)
      end
    end
    module Stream
      class Open < RIO::Stream::Open
        def input() stream_state('StrIO::Stream::Input') end
        def output() stream_state('StrIO::Stream::Output') end
        def inout() stream_state('StrIO::Stream::InOut') end
      end

      module Ops
        def string() ioh.string end
        def string=(p1) ioh.string = p1 end
      end

      class Input < RIO::Stream::Input
        include Ops
      end

      class Output < RIO::Stream::Output
        include Ops
      end

      class InOut < RIO::Stream::InOut
        include Ops
      end
    end
  end
end
