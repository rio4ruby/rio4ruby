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

module RIO
  module StdIO #:nodoc: all
    RESET_STATE = RRL::IOIBase::RESET_STATE

    class RRL < RRL::SysIOBase 
      RIOSCHEME = 'stdio'
      RIOPATH = RIO::RRL::CHMAP.invert[RIOSCHEME].to_s.freeze
      def initialize(u)
        super(u)
      end
      extend Forwardable
      def_delegators :uri, :path=, :path
      require 'rio/iomode'
      def open(m)
        case 
        when m.primarily_read? 
          uri.scheme = 'stdin'
          return super($stdin.clone)
        when m.primarily_write? 
          uri.scheme = 'stdout'
          return super($stdout.clone)
        else 
          raise ArgumentError,sprintf("Can not %s a %s with mode '%s'",'open',self.class,m)
        end
        nil
      end
      def close()
        uri.scheme = RIOSCHEME
        self.ios = nil
      end
    end
  end
end
