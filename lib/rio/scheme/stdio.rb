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


module RIO
  module StdIO #:nodoc: all
    require 'rio/rl/ioi'
    RESET_STATE = RL::IOIBase::RESET_STATE

    class RL < RL::SysIOBase 
      RIOSCHEME = 'stdio'
      RIOPATH = RIO::RL::CHMAP.invert[RIOSCHEME].freeze
      attr_reader :scheme
      def initialize(sch=RIOSCHEME)
        @scheme = sch
      end
      def opaque() '' end
      require 'rio/iomode'
      def open(m)
        case 
        when m.primarily_read? 
          @scheme = 'stdin'
          self.ios = $stdin.clone
        when m.primarily_write? 
          @scheme = 'stdout'
          self.ios = $stdout.clone
        else 
          raise ArgumentError,sprintf("Can not %s a %s with mode '%s'",'open',self.class,m)
        end
        super()
      end
      def close()
        @scheme = RIOSCHEME
        self.ios = nil
      end
    end
  end
end
