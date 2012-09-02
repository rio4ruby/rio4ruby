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
        #p "conncache: remote_root=#{@remote_root.inspect}"
        @remote_root
      end
      def _init_connection
        #p "_init_connection: uri=#{@uri.inspect}"
        @netftp = ::Net::FTP.new()
        #p @uri.host,@uri.port
        @netftp.connect(@uri.host,@uri.port||21)
        if @uri.user
          @netftp.login(@uri.user,@uri.password)
        else
          @netftp.login
        end
        @remote_root = @netftp.pwd
        @encoding = @remote_root.encoding
        #p "FTP._init_connection @remote_root=#{remote_root} enc=#{@remote_root.encoding}"
        # @remote_root = '' if @remote_root == '/'
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
#          c = @conns[key]
#          ObjectSpace.define_finalizer(c,proc { 
#                                         p "Quit and Close #{uri}"
#                                         if c and !c.closed?
#                                           c.quit 
#                                           c.close
#                                         end
#                                       })
          @count[key] = 0
        end
        @count[key] += 1
        @conns[key]
      end
      def close(uri)
        key = urikey(uri)
        @count[key] -= 1
        #p "Closed #{uri} count=#{@count[key]}"
      end
    end
  end
end
