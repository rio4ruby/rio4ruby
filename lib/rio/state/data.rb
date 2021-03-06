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

module RIO
  module State

    class Data
      attr :store
      def initialize(h={})
        @store = {}
        h.each do |k,v|
          @store[k] = v
        end
      end
      def initialize_copy(other)
        @store = other.store.clone
      end
      extend RIO::Fwd
      fwd :@store,:[]
      fwd_readers :@store,:keys
        
      def method_missing(sym,*args,&block)
        if sym.to_s.end_with?('=')
          key = sym.to_s.chop.to_sym
          @store[key] = args[0]
        else
          @store[sym]
        end
      end

    end
  end 
end # module RIO
