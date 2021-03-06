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
  module RecType #:nodoc: all
    module Lines
      module Input
        def get_arg_() $/ end
        def get_(sep_string=get_arg_)
          #p callstr('get_',sep_string.inspect)
          self.ior.gets(sep_string)
        end
        def io_enum
          self.ior.to_enum
        end
        def each_rec_(&block) 
          ih = self.ior
          ih.each_line { |line|
            yield line
          }
          self
        end
      end
      module Output
        def put_(rec,*args)
          #p callstr('put_',rec,*args)
          self.iow.print(rec.to_s)
        end  
      end
    end
    module Bytes
      module Input
        def get_arg_() 
          cx['bytes_n']  
        end
        def get_(nb=get_arg_())
          self.ior.read(nb)
        end
        def each_rec_(&block) 
          #p callstr('each_rec_ (EachIter::Bytes)')
          self.ior.each_bytes(cx['bytes_n']) { |b|
            yield b
          }
          self
        end
      end
      module Output
        def put_(rec,*args)
          #p callstr('put_',rec,*args)
          print(rec)
        end
      end
    end
  end
end
