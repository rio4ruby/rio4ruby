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


require 'rio/exception'
module RIO
  module Exception
    class State < Base; end
    class FailedCheck < State
      attr :obj
      def initialize(obj)
        super
        @obj = obj
      end
      def to_s() @obj.to_s end
    end
    class CantHandle < State
      attr :obj
      attr :sym
      attr :args
      def initialize(obj,sym,*args)
        super(obj)
        @obj = obj
        @sym = sym
        @args = args
      end
    end
    class Looping < State
      attr :obj
      attr :sym
      attr :args
      def initialize(obj,sym,*args)
        super(obj)
        @obj = obj
        @sym = sym
        @args = args
      end
    end

  end
end
