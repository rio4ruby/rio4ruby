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
          has_output_dest?(nrio) ? nrio.run :  nrio
        end
        #def last_rio(r)
        #  r.scheme == 'cmdpipe' ? last_rio(r.rl.query[-1]) : r
        #end
        def last_rio(r)
          r = r.rl.query[-1] while r.scheme == 'cmdpipe'
          r
        end

        def has_output_dest?(nrio)
          !%w[cmdio cmdpipe].include?(last_rio(nrio).scheme)
        end
        def run
          rios = get_rios(self)

          rio0 = rios.shift
          input = if rio0.scheme == 'cmdio'
                    rio0.rl.fib_proc(::RIO::Mode::Str.new("r"))
                  else
                    Cmd::FromEnum.new(rio0.to_enum)
                  end
          procs = []
          while rios.size > 1
            fp = rios.shift.rl.fib_proc(::RIO::Mode::Str.new('w+'))
            procs.unshift(fp) 
          end
          orio = rios.shift
          orio.touch if orio && orio.scheme.nil? # TODO: is this right???
          output = Cmd::ToOutput.new(orio)
          output.resume procs + [input]
          #p "RUN orio.scheme=#{orio.scheme}"
          orio
        end

        private

        def piper
          self.rl.piper
        end
        def get_rios(r)
          r.scheme == 'cmdpipe' ? r.rl.query.inject([]){|rios,r1| rios+get_rios(r1)} : [r]
        end

        def is_output_dest?(erio)
          erio.scheme != 'cmdio' && erio.scheme != 'cmdpipe'
        end
      end
    end
  end
end
