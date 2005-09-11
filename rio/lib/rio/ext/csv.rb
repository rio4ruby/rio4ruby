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


require 'csv'
require 'rio/record'

module RIO
  module Ext
    module CSV
      module Cx
        def csv(fs=',',rs=nil,&block) 
          cx['csv_fs'] = fs
          cx['csv_rs'] = rs
          cxx('csv',true,&block) 
        end
        def csv?() cxx?('csv') end 
        def csv_(fs=',',rs=nil) 
          cx['csv_fs'] = fs
          cx['csv_rs'] = rs
          cxx_('csv',true) 
        end
        protected :csv_
        def columns(*ranges,&block)
          if skipping?
            cx['skipping'] = false
            skipcolumns(*args,&block)
          else
            @cnames = nil
            cx['col_args'] = ranges.flatten
            cxx('columns',true,&block)
          end
        end
        def skipcolumns(*ranges,&block)
          @cnames = nil
          cx['nocol_args'] = ranges.flatten
          cxx('columns',true,&block)
        end
        def columns?() 
          cxx?('columns') 
        end 
      end
    end
  end
end
module RIO
  module Ext
    module CSV
      module Ary
        attr_accessor :csv_rec_to_s
        def to_s()
          @csv_rec_to_s.call(self)
        end
      end
      module Str
        attr_accessor :csv_s_to_rec
        def to_a()
          @csv_s_to_rec.call(self)
        end
      end
    end


    module CSV
      module Input

        protected

        def to_rec_(raw_rec)
          #_init_cols_from_line(raw_rec) if @recno == 0
          #p "#{callstr('to_rec_',raw_rec,@recno)} ; itertype=#{cx['stream_itertype']}"
          case cx['stream_itertype']
          when 'lines' 
            unless copying_from?
              raw_rec.extend(RIO::Ext::CSV::Str)
              raw_rec.csv_s_to_rec = _s_to_rec_proc(cx['csv_fs'],cx['csv_rs'])
            end
            raw_rec
          when 'records'
            _l2record(raw_rec,cx['csv_fs'],cx['csv_rs'])
          when 'rows'
            _l2row(raw_rec,cx['csv_fs'],cx['csv_rs'])
          else
            _l2record(raw_rec,cx['csv_fs'],cx['csv_rs'])
          end
        end

        private

        def trim(fields)
          ycols = cx['col_args']
          ncols = cx['nocol_args']
          return [] if ncols and ncols.empty?
          if ycols.nil? and ncols.nil?
            return fields
          end
          ncols = [] if ncols.nil?
          ycols = [(0...fields.size)] if ycols.nil? or ycols.empty?
          cols = []
          fields.each_index { |i|
            yes = nil
            no = nil
            ycols.each { |yc|
              if yc === i
                yes = true
                break
              end
            }
            ncols.each { |nc|
              if nc === i
                no = true
                break
              end
            }

            cols << i if yes and !no
          }
          tfields = []
          cols.each do |i|
            tfields << fields[i]
          end
          tfields
        end
        def _l2a(line,fs,rs)
          ::CSV.parse_line(line,fs,rs)
        end
        def _l2record(line,fs,rs)
          #p callstr('_l2record',line,fs,rs,cols)
          fields = trim(::CSV.parse_line(line,fs,rs))
          unless copying_from?
            fields.extend(RIO::Ext::CSV::Ary)
            fields.csv_rec_to_s = _rec_to_s_proc(fs,rs)
          end
          fields
        end
        def cnames(num)
          @cnames ||= trim((0...num).map { |n| "Col#{n}" })
        end

        def _l2row(line,fs,rs)
          dat = _l2a(line,fs,rs)
          names = cnames(dat.length)
          dat = trim(dat)
          (0...names.length).build_hash { |i| [names[i],dat[i]] } 
        end

        def _rec_to_s_proc(fs,rs)
          proc { |a|
            ::CSV.generate_line(a,fs,rs) 
          }
        end

        def _s_to_rec_proc(fs,rs)
          proc { |s|
            ::CSV.parse_line(s,fs,rs) 
          }
        end

        def _init_cols_from_line(line)
          ary = _l2record(line,cx['csv_fs'],cx['csv_rs'])
          _init_cols_from_ary(ary)
        end

        def _init_cols_from_num(num)
          fake_rec = (0...num).map { |n| "Column#{num}" }
          _init_cols_from_ary(fake_rec)
        end
        def _init_cols_from_hash(hash)
          _init_cols_from_ary(hash.keys)
        end
        def _init_cols_from_ary(ary)
          #p callstr('_init_cols_from_ary',ary)
          if columns?
            cx['col_names'] = []
            cx['col_nums'] = []

            ary.each_with_index do |cname,idx|
              cx['col_args'].each do |arg|
                if arg === ( arg.kind_of?(::Regexp) || arg.kind_of?(::String) ? cname : idx )
                  cx['col_names'] << cname
                  cx['col_nums'] << idx
                end
              end
            end
          else
            cx['col_names'] = ary
          end
          cx.values_at('col_nums','col_names')
        end

      end
    end

    module CSV
      module Output

        public

        def putrow(*argv)
          require 'csv'
          row = ( argv.length == 1 && argv[0].kind_of?(::Array) ? argv[0] : argv )
          self.puts(::CSV.generate_line(row,self.cx['csv_fs'],self.cx['csv_rs']))
        end
        def putrow!(*argv)
          putrow(*argv)
          close
        end

        protected

        def put_(arg,fs=cx['csv_fs'],rs=cx['csv_rs'])
          #p callstr('put_',arg.inspect,fs,rs)
          @header_line ||= _to_header_line(arg,fs,rs)
          puts(_to_line(arg,fs,rs))
        end

        def cpfrom_array_(ary)
          #p callstr('copy_from_array',ary.inspect)
          if ary.empty?
            super
          else
            if ary[0].kind_of? ::Array
              super
            else
              put_(ary)
            end
          end
        end

        private

        def _to_header_line(arg,fs=cx['csv_fs'],rs=nil)
          case arg
          when ::String
            arg
          when ::Array
            _ary_to_line(arg,fs,rs)
          when ::Hash
            _ary_to_line(arg.keys,fs,rs)
          else
            arg.to_s
          end
        end

        def _to_line(arg,fs=cx['csv_fs'],rs=cx['csv_rs'])
          #p callstr('_to_line',arg.inspect,fs,rs)
          case arg
          when ::Array
            _ary_to_line(arg,fs,rs)
          when ::Hash
            _ary_to_line(arg.values,fs,rs)
          else
            arg
          end
        end

        def _ary_to_line(ary,fs,rs)
          rs ||= $/
          ::CSV.generate_line(ary,fs,rs)
        end
        public
      end
    end
  end
end
__END__
