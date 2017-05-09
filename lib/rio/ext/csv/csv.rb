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

class StringIO
  def to_io() self end
end
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
        def headers(*args,&block) 
          if args.empty?
            cx['headers_args'] = true
          else
            cx['headers_args'] = args[0]
            cx['headers'] = cx['headers_args']
          end
          cxx('csv',true,&block) 
        end
        def headers?()
          unless cx['headers']
            cx['headers'] = self.records[0]
          end
          cxx?('headers') 
        end 

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
        def fields(*ranges,&block)
          if skipping?
            cx['skipping'] = false
            skipfields(*args,&block)
          else
            @cnames = nil
            cx['fields_args'] = ranges.flatten
            cxx('fields',true,&block)
          end
        end
        def skipfields(*ranges,&block)
          @cnames = nil
          cx['nofields_args'] = ranges.flatten
          cxx('fields',true,&block)
        end
        def fields?() 
          cxx?('fields') 
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

        def contents()                  
          _post_eof_close { 
            self.to_io.read || "" 
          }         
        end

        protected

        def get_(sep_string=get_arg_)
          #p callstr('get_',sep_string.inspect)
          self.ior.gets
        end
        def cpto_string_(arg)
          if cx['stream_itertype'].nil?
            get_type('lines') { super }
          else
            super
          end
        end
        def cpto_rio_(arg,sym)
          #p callstr('csv:cpto_rio_',arg.inspect)
          ario = ensure_rio(arg)
          ario = ario.join(self.filename) if ario.dir?
          ario.cpclose {
            ario = ario.iostate(sym)
            self.copying(ario).each { |el|
              case el
              when ::Array
                ario.putrec(el)
              else
                ario.putrec(el.parse_csv(*ario.cx['csv_args']))
              end
            }.copying_done(ario)
            ario
          }
        end

        def to_rec_(raw_rec)
          if ::CSV::Row === raw_rec
            unless cx['field_args'].nil?
              cx['csv_columns'] ||= []
              cx['csv_columns'] += fields_to_columns(raw_rec.headers,cx['field_args'])
              cx['field_args'] = nil
            end
          end
          raw_rec
        end

        private

        private
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
          row = ( argv.length == 1 && argv[0].kind_of?(::Array) ? argv[0] : argv )
          self.puts(::CSV.generate_line(row,*cx['csv_args']))
        end
        def putrow!(*argv)
          putrow(*argv)
          close
        end

        def putrec(rec,*args)
          #p callstr('csv:putrec',rec.inspect,args.inspect)
          case rec
          when ::Array
            self.puts(rec)
          else
            self.puts(rec.parse_csv)
          end
          self
        end
        protected

        def cpfrom_(arg)
          #p callstr('cpfrom_',arg.inspect)
          case arg
          when ::String
            ::CSV.parse(arg,*cx['csv_args']) {|el| puts(el) }
          else 
            super
          end
          self
        end

        def cpfrom_rio_(arg)
          #p callstr('csv:cpfrom_rio_',arg.inspect)
          
          ario = ensure_rio(arg)
          ario.copying(self).each { |el|
            case el
            when ::Array
              self.puts(el)
            else
              self.puts(el.parse_csv(*cx['csv_args']))
            end
          }.copying_done(self)
        end

        def put_(arg)
          #p callstr('put_',arg.inspect)
          puts(arg)
        end

        def cpfrom_array_(ary)
          #p callstr('copy_from_array',ary.inspect)
          if ary.empty?
            super
          else
            case ary[0]
            when ::Array, ::CSV::Row
              #p callstr('copy_from_array_of_array_or_rows',ary.inspect)
              ary.each do |el|
                puts(el)
              end
            else
              #p callstr('copy_from_array_of_objs',ary.inspect)
              ary.each do |el|
                puts(el.parse_csv(*cx['csv_args']))
              end
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
          p callstr('_to_line',arg.inspect,csv_args)
          case arg
          when ::Array
            _ary_to_line(arg,*csv_args)
          when ::Hash
            _ary_to_line(arg.values,*csv_args)
          else
            arg
          end
        end
        def _csv_options(*args)
        end
        def _ary_to_line(ary,*csv_args)
          rs ||= $/
          _csv_options(csv_args)
          ::CSV.generate_line(ary,*csv_args)
        end
        public
      end
    end
  end
end
__END__
