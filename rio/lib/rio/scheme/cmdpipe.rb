#--
# =============================================================================== 
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
# =============================================================================== 
#++
#
# To create the documentation for Rio run the command
#  ruby build_doc.rb
# from the distribution directory.
#
# Suggested Reading
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Doc::EXAMPLES
# * RIO::Rio
#


require 'rio/rrl/ioi'
require 'rio/stream'
require 'rio/stream/open'
require 'rio/piper'
require 'rio/cxuri'
require 'rio/scheme/cmdio'
require 'rio/fibpipe'

module RIO
  module CmdPipe #:nodoc: all
    RESET_STATE = 'CmdPipe::Stream::Reset'

    class RRL < RRL::IOIBase 
      RIOSCHEME = 'cmdpipe'
      RIOPATH = RIO::RRL::CHMAP.invert[RIOSCHEME].to_s.freeze
      attr_reader :piper

      def initialize(u, *args)
        #p u
        #args.each do |arg|
        #  puts arg
        #end
        nuri = case u
               when ::Alt::URI::Base,RIO::CmdPipe,RIO::CmdIO 
                 u
               else ::Alt::URI.parse(u)
               end
        super(nuri)

        case uri.scheme
        when 'cmdio'
          rios = args.map{ |el| ensure_rio(el) }
          self.query = [ensure_rio(uri),rios]
        when 'cmdpipe'
          rios = args.map{ |el| ensure_rio(el) }
          self.append_to_query(rios)
        else
          rios = args.map{ |el| ensure_rio(el) }
          self.query = [ensure_rio(uri),rios]
        end
      end
      def ensure_rio(arg)
        case arg
        when RIO::Rio then arg
        when RIO::State::Base then arg.clone_rio
        else RIO::Rio.new(arg)
        end
      end
      def self.parse(*a)
        u = a.shift.sub(/^rio:/,'')
        new(u,*a)
      end
      def query=(a)
        uri.query = if a.instance_of?(::Array)
                      a.map{ |el| CxURI.new(ensure_rio(el)).to_s }
                    else
                     CxURI.new(ensure_rio(a)).to_s
                    end
      end
      def query
        v = uri.query
        case v
        when nil then v
        when ::Array
          v.map{ |el| CxURI.new(el).to_rio }
        else
          CxURI.new(v).to_rio
        end
      end

      def append_to_query(rios)
        q = self.query
        case q
        when nil
          self.query = rios
        when Alt::URI::Base
          self.query = [rios].flatten
        when ::Array
          self.query = q + [rios].flatten
        else
          raise ArgumentError, "append_to_query: #{q}, #{uris}"
        end
      end
      def initialize_copy(other)
        super
      end
      def to_s()
        super
      end
      def run
        rios = self.query
        (1...rios.size-1).each { |i| rios[i].w! }
        (1...rios.size).each { |i|
          rios[i-1] > rios[i]
        }
        rios.each { |r| r.close.softreset }
        rios[-1]
      end
      def open(m,*args)
        run
      end
    end
    module Stream
      class Reset < State::Base
        include Ops::Path::URI
        def check?() true end
        def |(arg)
          ario = ensure_cmd_rio(arg)
          nrio = new_rio(self,ario)
          end_rio = nrio.rl.query[-1]
          has_output_dest = end_rio.scheme != 'cmdio'
          # p "cmdpipe.rb ! before run #{nrio.inspect}"
          if has_output_dest
            nrio.run
          end
          # p "cmdpipe.rb ! returning #{nrio.inspect}"
          nrio
        end
        def run
          # p 'RUNNING'
          rios = self.rl.query
          rio0 = rios.shift
          input = if rio0.scheme == 'cmdio'
                    rio0.rl.fib_proc(::RIO::Mode::Str.new("r"))
                  else
                    Cmd::FromEnum.new(rio0.to_enum)
                  end
          procs = []
          while rios.size > 1
            r = rios.shift
            fp = r.rl.fib_proc(::RIO::Mode::Str.new('w+'))
            procs.unshift(fp) 
          end
          output = Cmd::ToOutput.new(rios.shift)
          output.resume procs + [input]
        end
        def piper
          self.rl.piper
        end
        def has_output_dest?
          piper.has_output_dest?
        end
#        def when_missing(sym,*args)
#          #p callstr('when_missing',sym,*args)
#          become 'CmdPipe::Stream::Open'
#        end
      end
    end
  end
end
