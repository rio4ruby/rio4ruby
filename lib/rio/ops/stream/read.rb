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
  module Ops
    module Stream
      module Read

        private

        def _post_eof_close(&block)
          rtn = yield
          self.close if closeoneof?
          rtn
        end
        def _pre_eof_close(&block)
          begin
            closit = ior.eof? && closeoneof?
            rtn = yield
          ensure
            self.close if closit
          end
          rtn
        end

        public

        def contents()                  _post_eof_close { ior.read || "" }         end
        def readlines(*args)            _post_eof_close { ior.readlines(*args) }        end
        def each_line(*args,&block)     
          _post_eof_close { ior.each_line(*args,&block) } 
        end
        def each_byte(*args,&block)     _post_eof_close { ior.each_byte(*args,&block) } end
        def each_bytes(nb,*args,&block) _post_eof_close { ior.each_bytes(nb,&block) }   end

        def read(*args)                 _pre_eof_close { ior.read(*args) }               end
        def gets(*args)                 _pre_eof_close { ior.gets(*args) }               end
        def readline(*args)             _pre_eof_close { ior.readline(*args) }           end
        def readpartial(*args)          _pre_eof_close { ior.readpartial(*args) }        end
        def readchar(*args)             _pre_eof_close { ior.readchar(*args) }           end
        def getc(*args)                 _pre_eof_close { ior.getc(*args) }               end

        def ungetc(*args)
          ior.ungetc(*args)
          self
        end
        def lineno()     ior.lineno       end
        def lineno=(arg) ior.lineno = arg end
      end 
    end 
  end
end
