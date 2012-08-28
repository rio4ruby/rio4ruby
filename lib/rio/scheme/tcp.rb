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
# ==== Rio - Ruby I/O Facilitator
#
# Rio is a facade for most of the standard ruby classes that deal with
# I/O; providing a simple, intuitive, succinct interface to the
# functionality provided by IO, File, Dir, Pathname, FileUtils,
# Tempfile, StringIO, OpenURI and others. Rio also provides an
# application level interface which allows many common I/O idioms to be
# expressed succinctly.
#
# ===== Suggested Reading
#
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Doc::EXAMPLES
# * RIO::Rio
#
# Project::       http://rubyforge.org/projects/rio/
# Documentation:: http://rio4ruby.com/
# Bugs::          http://rubyforge.org/tracker/?group_id=821
# Blog::          http://rio4ruby.blogspot.com/
# Email::         rio4ruby@rubyforge.org
#


require 'rio/rl/base'
module RIO
  module TCP #:nodoc: all
    RESET_STATE = 'Stream::Duplex::Open'
    require 'rio/rl/ioi'
    class RL < RL::IOIBase 
      RIOSCHEME = 'tcp'.freeze
      attr_reader :host
      def initialize(host,port)
        @host = host
        @port = port
        super
      end
      def opaque()
        sprintf('//%s:%s',@host,@port)
      end
      require 'socket'
      def open(*args)
        #          @host = 'localhost' if @host.nil? or @host.empty?
        super(::TCPSocket.new(@host || 'localhost',@port))
      end
      def to_s() self.url end
      
      # must be able to process
      # parse('rio:tcp',host,port)
      # parse('rio:tcp://host:port')
      SPLIT_RE = %r|//([^/:]*):([0-9a-z]+)$|.freeze
      def self.splitrl(s)
        sub,opq,whole = split_riorl(s)
        if bm = SPLIT_RE.match(opq)
          host = bm[1]
          port = bm[2]
          host = nil if host.empty?
          [host,port]
        end
      end
    end
  end
end
