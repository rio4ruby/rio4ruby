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


require 'rio/exception/state'
module RIO

  module State
    class Error < Base
      attr_accessor :obj,:msg,:sym
      fwd :data,:obj,:msg,:sym
      def check?() true end
      def when_missing(sym,*args) self end
      def method_missing(sym,*args,&block)
        emsg = sprintf("Can't Handle %s[%s].%s(%s)",@obj.class.to_s,@obj.to_s,sym.to_s,args.join(','))
        raise Exception::CantHandle.new(@obj,sym,*args),emsg
      end
      def self.error(emsg,obj,sym,*args)
        require 'rio/exception'
        msg = sprintf("%s[%s].%s(%s)",obj.class.to_s,obj.to_s,sym.to_s,args.join(','))
        msg += "\n  "+emsg unless emsg.nil? or emsg.empty?
        new(obj: obj, sym: sym, msg: msg)
      end
    end
  end 

end # module RIO
