#--
# =============================================================================== 
# Copyright (c) 2005, Christopher Kleckner
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
#  rake rdoc
# from the distribution directory. Then point your browser at the 'doc/rdoc' directory.
#
# Suggested Reading
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Rio
#
# <b>Rio is pre-alpha software. 
# The documented interface and behavior is subject to change without notice.</b>


# T-Mobile HotSpot 1.877.822.SPOT
require 'rio/matchrecord'
require 'rio/arycopy'
require 'rio/grande'
require 'rio/rectype'
require 'rio/ops/stream/read'
require 'rio/context/stream'
require 'stringio'
require 'rio/record'
require 'rio/cp'


module RIO
  module Ops
    module Stream
      module Input
        include Status
        include Ops::Stream::Read
        include Enumerable
        include Grande
        include Cp::Stream::Input
      end
    end
  end
end
module RIO
  module Ops
    module Stream
      module Input
        public

        def each(*args,&block)
          #p callstr('each',*args)
          each_(*args,&block)
          self
        end

        def each_record(*args,&block)
          #p callstr('each_record',*args)
          each_record_(*args,&block)
          self
        end

        def each_row(*args,&block) 
          #p callstr('each_row',*args)
          rows(*args).each_row_(*args,&block)
          self
        end

        def getrec()
          until self.eof?
            raw_rec = self._get_rec
            return to_rec_(raw_rec) if @get_selrej.match?(raw_rec,@recno)
          end
        end
        private

        def _ss_like_array(selrej)
          selrej.only_one_fixnum? and !dir_iter?
        end

        protected

        # iterate over the records, yielding only with matching records
        # implemented in terms of an underlying iterator like each_line (see RIO::RecType::*)
        def each_(*args,&block)
          #p callstr('each_',*args)
          selrej,rangetops = create_selrej()
          want_ma = block.arity > 1
          catch(:stop_iter) do
            each_rec_ do |raw_rec|
              _got_rec(raw_rec)
              rangetops = check_passed_ranges(selrej,@recno) if rangetops and @recno > rangetops[0]
              if as = selrej.match?(raw_rec,@recno)
                if want_ma
                  yield(to_rec_(raw_rec),as)
                else
                  yield(to_rec_(raw_rec))
                end
              end
            end
            return self
          end
          closeoneof? ? ioh.close_on_eof_(self) : self
        end

        # iterate over the records, yielding only with matching records
        # implemented in terms of get_ (see RIO::RecType::*)
        def each_record_(*args,&block)
          #p callstr('each_record_',*args)

          selrej,rangetops = self.create_selrej()
          get_arg = self.get_arg_
          self.each_record_init_(*args)
          catch(:stop_iter) {
            until ioh.eof?
              break unless raw_rec = self._get_rec(get_arg)
              rangetops = check_passed_ranges(selrej,@recno) if rangetops and @recno > rangetops[0]
              yield to_rec_(raw_rec) if selrej.match?(raw_rec,@recno)
            end
            return self
          }
          closeoneof? ? ioh.close_on_eof_(self) : self
        end
        alias :each_row_ :each_
        def clear_selection()
          cx.delete('stream_sel')
          cx.delete('stream_nosel')
          self
        end
        def _get_rec(arg=get_arg_)
          _got_rec(self.get_(arg))
        end

        def to_rec_(record)
          record
        end

        private

        def _got_rec(el=nil)
          @recno += 1 unless el.nil?
          el
        end

        protected

        def each_record_init_
        end

        def create_selrej()
          sel_args = cx['stream_sel']
          nosel_args = cx['stream_nosel']
          selrej = RIO::Match::Record::SelRej.new(self,sel_args,nosel_args)
          [selrej,selrej.rangetops]
        end

        def check_passed_ranges(selrej,recno)
          throw :stop_iter if selrej.remove_passed_ranges(recno).never?
          selrej.rangetops
        end

        def on_closeoneof
          #p "on_closeoneof #{self.object_id} #{self.ioh.object_id}"
          self.close
        end

        private

        def _ss_keys() Cx::SS::STREAM_KEYS end

        def auto(&block)
          rewind if autorewind?
          yield 
        end

        public
        
        def rewind(&block)
          self.ioh.rewind
          @recno = -1
          each(&block) if block_given?
          self
        end

        def close_read(&block)
          self.ioh.close_read
          each(&block) if block_given?
          self
        end

        def copy_stream(dst)
          #p callstr('copy_stream',dst)
          ioh.copy_stream(dst)
          self
        end

        def recno()
          return nil unless @recno >= 0
          @recno
        end

        def to_h
          { self.to_s => self.to_a }
        end
          

        def each_0(sel,&block)
          if sel.match_all?
            each_rec_(&block)
          else
            each_rec_ { |rec|
              next unless mtch = sel.match?(rec,@recno)
              val = (mtch.kind_of?(::MatchData) && mtch.size > 1 ? mtch.to_a[1...mtch.length] : rec)
              yield val
            }
          end
          self
        end
      end
    end
  end
end