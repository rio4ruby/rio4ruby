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
      autoload :Input,'rio/ops/stream/input'
      autoload :Output,'rio/ops/stream/output'
    end
  end
end
module RIO
  module Impl
    module U
    end
  end
  module Ops
    module Stream
      module Status
        def open?() 
          not self.closed?
        end
        def closed?() self.ioh.nil?  end
        def eof?() closed? or ior.eof? end
        def stat() ioh ? ioh.stat : nil end # 
      end
    end

    module Stream
      module Manip
        def pid() ioh ? ioh.pid : nil end
        def to_io() ioh ? ioh.to_io : nil end
        def tty?() ioh ? ioh.tty? : false end
        def isatty() ioh ? ioh.isatty : false end
        def flush() rtn_self { self.ioh.flush } end
        def fsync() rtn_self { self.ioh.fsync } end
        def seek(amount,whence=IO::SEEK_SET) rtn_self { self.ioh.seek(amount,whence) } end
        extend RIO::Fwd
        fwd :ioh,:pos
        fwd_readers :ioh, :fileno, :to_i, :fcntl, :ioctl
      end
    end
    module Stream
      module Open
      end
    end
    module Stream
      module Copy
      end
    end
    module Stream
      module Close
      end
    end
    module Stream
      module Reset
        include Status
      end
    end
  end
end
