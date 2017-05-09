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

$EXTEND_CSV_RESULTS = false
module RIO
  module Ext
    module CSV
      module Cx
        def csv(*args,&block) 
          cx['csv_args'] = args
          cxx('csv',true,&block) 
        end
        def csv?() cxx?('csv') end 
        def csv_(*args) 
          cx['csv_args'] = args
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
  end
end


module RIO
  module Ext
    module CSV
      module Input

        protected
        def to_rec_(raw_rec)
          case cx['stream_itertype']
          when 'lines' 
            if $EXTEND_CSV_RESULTS
              unless copying_from?
                raw_rec.extend(RIO::Ext::CSV::Str)
                raw_rec.csv_s_to_rec = _s_to_rec_proc(*cx['csv_args'])
              end
            end
            #p raw_rec
            raw_rec
          when 'records'
            _l2record(raw_rec)
          when 'rows'
            _l2row(raw_rec)
          else
            _l2record(raw_rec)
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
        def parse_line_(line)
          line.chomp!
          ::CSV.parse_line(line,*cx['csv_args'])
        end
        def _l2a(line)
          parse_line_(line)
        end
        def _l2record(line)
          #p callstr('_l2record',line)
          fields = trim(parse_line_(line))
          if $EXTEND_CSV_RESULTS
            unless copying_from?
              fields.extend(RIO::Ext::CSV::Ary)
              fields.csv_rec_to_s = _rec_to_s_proc(*cx['csv_args'])
            end
          end
          fields.map{ |f| f.to_s }
        end
        def cnames(num)
          @cnames ||= trim((0...num).map { |n| "Col#{n}" })
        end

        def _l2row(line)
          dat = _l2a(line)
          names = cnames(dat.length)
          dat = trim(dat)
          rw = {}
          (0...names.length).each { |i|
            rw[names[i]] = dat[i]
          }
          rw
        end

        def _rec_to_s_proc(*csv_args)
          proc { |a|
            ::CSV.generate_line(a,*csv_args) 
          }
        end

        def _s_to_rec_proc(*csv_args)
          proc { |s|
            ::CSV.parse_line(s,*csv_args) 
          }
        end

        def _init_cols_from_line(line)
          ary = _l2record(line)
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
          self.puts(::CSV.generate_line(row,*cx['csv_args']))
        end
        def putrow!(*argv)
          putrow(*argv)
          close
        end

        protected

        def put_(arg)
          #p callstr('put_',arg.inspect)
          @header_line ||= _to_header_line(arg,*cx['csv_args'])
          puts(_to_line(arg,*cx['csv_args']))
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

        def _to_header_line(arg,*csv_args)
          case arg
          when ::String
            arg
          when ::Array
            _ary_to_line(arg,*csv_args)
          when ::Hash
            _ary_to_line(arg.keys,*csv_args)
          else
            arg.to_s
          end
        end

        def _to_line(arg,*csv_args)
          #p callstr('_to_line',arg.inspect,csv_args)
          case arg
          when ::Array
            _ary_to_line(arg,*csv_args)
          when ::Hash
            _ary_to_line(arg.values,*csv_args)
          else
            arg
          end
        end

        def _ary_to_line(ary,*csv_args)
          rs ||= $/
          ::CSV.generate_line(ary,*csv_args)
        end
        public
      end
    end
  end
end
__END__
