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


require 'net/ftp'
require 'rio/alturi'
require 'singleton'

module RIO
  module FTP
    class Connection
      attr_reader :uri,:netftp,:encoding
      def initialize(uri)
        @uri = uri.clone
        @netftp = nil
        @remote_root = nil
        @encoding = nil
        _init_connection()
      end
      def remote_root
        @remote_root
      end
      def _init_connection
        @netftp = ::Net::FTP.new()
        @netftp.connect(@uri.host,@uri.port||21)
        if @uri.user
          @netftp.login(@uri.user,@uri.password)
        else
          @netftp.login
        end
        @remote_root = @netftp.pwd
        @encoding = @remote_root.encoding
      end
      def method_missing(sym,*args,&block)
        @netftp.__send__(sym,*args,&block)
      end
    end
    class ConnCache
      include Singleton
      def initialize()
        @conns = {}
        @count = {}
      end
      def urikey(uri)
        key_uri = uri.clone
        key_uri.path = ''
        key_uri.to_s
      end
      def connect(uri)
        key = urikey(uri)
        unless @conns.has_key?(key)
          @conns[key] = Connection.new(uri)
          @count[key] = 0
        end
        @count[key] += 1
        @conns[key]
      end
      def close(uri)
        key = urikey(uri)
        @count[key] -= 1
      end
    end
  end
end
