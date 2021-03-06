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


require 'rio/rrl/base'
require 'rio/ioh'
require 'rio/fs/stream'

module RIO
  module RRL
    class IOIBase < Base
      RESET_STATE = 'Stream::Open'
      def openfs_()
        RIO::FS::Stream.create()
      end
      def scheme() self.class.const_get(:RIOSCHEME) end
      def opaque() '' end
      def fspath() nil end
      def path() uri.path end
      def to_s() url() end
      def open(ios)
        IOH::Stream.new(ios)
      end
    end
  end
  module RRL
    class SysIOBase < IOIBase
      attr_reader :ios
      attr_writer :ios
      protected(:ios=)
      def initialize(u,*args)
        alturi = case u
                 when ::Alt::URI::Base then u
                 else ::Alt::URI.parse(u.to_s)
                 end
        super(alturi)
        @ios = args.shift
      end
      def self.parse(*a)
        u = a.shift.sub(/^rio:/,'')
        new(u,*a)
      end

      def initialize_copy(cp)
        super
        @ios = cp.ios.clone unless cp.ios.nil? or cp.ios.closed?
      end
      def open(ios=nil)
        @ios = ios unless ios.nil?
        super(@ios)
      end
        
    end
  end
end
