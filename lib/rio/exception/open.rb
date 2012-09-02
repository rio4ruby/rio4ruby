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


require 'rio/exception'
module RIO
  module Exception
    class Open < Base
      attr :obj
      def initialize(obj,syse ,*args)
        @obj = obj
        @syserr = syse
      end
      def explain()
#         s = "#{self.class}: failed copying '#{@src}' => #{@dst}"
#         s += submsg("Err: #{@syserr}") if @syserr
#         s += submsg("Src: '#{@src}' " + finfo(@src))
#         s += submsg("Dst: '#{@dst}' " + finfo(@dst))
#         target = ::RIO::rio(@dst,@src.filename) if @dst.dir?
#         p target
#         if target.exist?
#           s += submsg("Tgt: '#{target} " + finfo(target))
#         end
                              
#         s += "\n"
      end
    end
  end
end
