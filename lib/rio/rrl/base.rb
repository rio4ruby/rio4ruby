#--
# ===========================================================================
# Copyright (c) 2005,2006,2007,2008,2009,2010 Christopher Kleckner
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
#
module RIO
  module RRL
    autoload :CHMAP, 'rio/rrl/chmap'
  end
end




module RIO
  module RRL

    class Base
      attr_accessor :fs, :uri
      def initialize(u,fs=nil)
        @uri = u
        @fs ||= openfs_
      end
      def initialize_copy(other)
        super
        @fs = other.fs if other.fs
        @uri = other.uri.clone if other.uri
      end
      def self.parse(*a)
        u = a.shift.sub(/^rio:/,'')
        new(u,*a)
      end

      def openfs_() 
        nil 
      end
      def to_s() uri.to_s end
      def ==(other) self.to_s == other.to_s end
      def ===(other) self == other end
      def =~(other) other =~ self.to_str end
      def length() self.to_s.length end

      extend Forwardable
      def url() uri.to_s end
      
      def close() 
        nil 
      end

      def callstr(func,*args)
        self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
      end
    end
  end
end

