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
  autoload :Stream, 'rio/stream'
end

require 'rio/rrl/withpath'
require 'rio/ops'
require 'rio/ioh'



module RIO
  module RRL
    class PathBase < URIBase
      RESET_STATE = 'Path::Reset'
      def to_s() self.fspath || '' end
    end
  end
end

module RIO
  module Path
    autoload :Reset, 'rio/path/reset'
  end
end

module RIO
  module Path #:nodoc: all
    RESET_STATE = RIO::RRL::PathBase::RESET_STATE

    class RRL < RIO::RRL::PathBase 
      def file_rl()
        RIO::File::RRL.new(self.uri, {:fs => self.fs})
      end
      def dir_rl()
        RIO::Dir::RRL.new(self.uri, {:fs => self.fs})
      end
    end
  end
  module File
    RESET_STATE = RIO::RRL::PathBase::RESET_STATE

    class RRL < RIO::Path::RRL
      def open(m)
        IOH::Stream.new(fs.file.open(self.fspath,m.to_s))
      end
      def file_rl()
        self
      end
    end
  end
  module Dir
    RESET_STATE = RIO::RRL::PathBase::RESET_STATE

    class RRL < RIO::Path::RRL
      def open()
        IOH::Dir.new(fs.dir.open(self.fspath))
      end
      def dir_rl()
        self
      end
    end
  end
  module Path
    module Stream
      module Ops
        include RIO::Ops::Path::Str
      end

      class Open < RIO::Stream::Open
        include RIO::Ops::Path::Status
        include RIO::Ops::Path::URI
        include RIO::Ops::Path::Query
        def stream_state(cl)
          next_state = super
          next_state.extend(RIO::Ops::Symlink::Existing) if symlink?
          next_state.extend(Ops)
        end
      end
    end
  end
end
__END__
