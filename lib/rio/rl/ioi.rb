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


require 'rio/rl/base'

module RIO
  module RL
    class IOIBase < Base
      RESET_STATE = 'Stream::Open'
      def scheme() self.class.const_get(:RIOSCHEME) end
      def opaque() '' end
      def self.splitrl(s) nil end
      #def path() self.class.const_get(:RIOPATH) end
      def path() nil end
      def fspath() nil end
      def to_s() url() end
    end
  end
  module RL
    class SysIOBase < IOIBase
      attr_reader :ios
      attr_writer :ios
      protected(:ios=)
      def initialize(ios=nil)
        @ios = ios
      end
      def open(*args)
        @ios
      end
        
    end
  end
end
