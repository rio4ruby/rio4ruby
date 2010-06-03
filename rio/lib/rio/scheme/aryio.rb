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

__END__
require 'rio/rl/ioi'
require 'rio/arrayio'
require 'rio/stream'
require 'rio/stream/open'

module RIO
  module AryIO #:nodoc: all

    class RL < RL::IOIBase 
      RIOSCHEME = 'aryio'
      RIOPATH = RIO::RL::CHMAP.invert[RIOSCHEME].freeze
      def initialize(ary=[])
        #p "#{callstr('initialize',ary.inspect)}"
        @ary = ary
      end
      def open(m,*args)
        #p "#{callstr('open',m,args.inspect)} ary=#{@ary.inspect}"
        @ary = args.shift unless args.empty?
        #p "#{callstr('open',m,args)} ary=#{@ary.inspect}"
        RIO::ArrayIO.new(@ary,m.to_s,*args)
      end
    end
    module Stream
      module Ops
        def array() ioh.array end
        def array=(p1)
          ioh.array = p1 
        end
      end
      class Open < RIO::Stream::Open
        include Ops
        def input() stream_state('AryIO::Stream::Input') end
        def output() stream_state('AryIO::Stream::Output') end
        def inout() stream_state('AryIO::Stream::InOut') end
      end


      class Input < RIO::Stream::Input
        include Ops
      end

      class Output < RIO::Stream::Output
        include Ops
      end

      class InOut < RIO::Stream::InOut
        include Ops
      end
    end
    RESET_STATE = 'AryIO::Stream::Open'
  end
end
