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


require 'rio/base'

module RIO
  class Handle < Base #:nodoc: all
    attr_accessor :target
    def initialize(st=nil) 
      @target = st 
    end
    def initialize_copy(*args)
      #p callstr('initialize_copy',*args)
      super
      @target = @target.clone
    end
    def method_missing(sym,*args,&block)
      #  p callstr('method_missing',*args)
      @target.__send__(sym,*args,&block)
    end
    def t_instance_of?(*args) @target.instance_of?(*args) end
    def t_kind_of?(*args) @target.kind_of?(*args) end
    def t_class(*args) @target.class(*args) end
    def to_s() @target.to_s() end
    def split(*args,&block) @target.split(*args,&block) end
    def callstr(func,*args)
      self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
    end
  end
end

if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

__END__
