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


module RIO
  module SysIO #:nodoc: all
    require 'rio/rrl/ioi'
    RESET_STATE = RRL::IOIBase::RESET_STATE

    class RRL < RRL::SysIOBase
      RIOSCHEME = 'sysio'
      RIOPATH = RIO::RRL::CHMAP.invert[RIOSCHEME].to_s.freeze
      def initialize(u,arg=nil)
        super(::Alt::URI.parse(u),arg)
        self.query ||= ios unless ios.nil?
      end
      def query=(arg)
        uri.query = arg.nil? ? nil : sprintf('0x%08x',arg.object_id)
        arg
      end
      def query
        uri.query.nil? ? nil :  ObjectSpace._id2ref(uri.query.hex)
      end

      def open(*args)
        super(self.ios)
      end
    end
  end
end
