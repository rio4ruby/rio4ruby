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


require 'rio/alturi'
require 'rio/rl/withpath'
require 'rio/rl/pathmethods'

module RIO
  module RL
    class PathBase < URIBase
      RESET_STATE = 'Path::Reset'

      def arg0_info_(arg0,*args)
        vuri,vbase,vfs = nil,nil,nil
        case arg0
        when RIO::Rio, URIBase, ::Alt::URI::Base, ::Alt::URI::File
          return super
        when ::String 
          vuri = uri_from_string_(arg0) || ::Alt::URI.parse(arg0)
        else
          raise(ArgumentError,"'#{arg0}'[#{arg0.class}] can not be used to create a Rio")
        end
        [vuri,vbase,vfs]
      end
      def build_arg0_(path_str)
        RL.url2fs(path_str)
      end
      def scheme() 
        uri.scheme || 'path' 
      end
      def url
        str = uri.to_s
        str = scheme + ':' +str unless uri.scheme
        str
      end
      def use_host?
        hst = uri.host
        !(hst.nil? || hst.empty? || hst == 'localhost')
      end

      def join(*args)
        return self if args.empty?
        join_(args.map{ |arg| arg.to_s})
      end
      def to_s()
        self.fspath
      end
      def self.splitrl(s)
        sch,opq,whole = split_riorl(s)
        case sch
        when 'file' then [whole]
        else [opq]
        end
      end
    end
  end
end
__END__
