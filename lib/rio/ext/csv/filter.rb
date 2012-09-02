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


module RIO
  module Ext
    module CSV
      module Filter
        module CSVMissing
          def set_cx(context)
            @cx = context
          end
          def cx() @cx end
          def _calc_csv_fields(row)
            num_cols = row.size-1

            require 'rio/arraynge'
            ycols = _fields_to_columns(row,cx['col_args']) unless cx['col_args'].nil?
            ncols = _fields_to_columns(row,cx['nocol_args'])  unless cx['nocol_args'].nil?
            #p "ycols=#{ycols.inspect} ncols=#{ncols.inspect}"
            if ncols and ncols.empty?
              cx['csv_columns'] = []
            elsif ycols.nil? and ncols.nil?
              cx['csv_columns'] = nil
            else
              ncols = [] if ncols.nil?
              ycols = [(0..-1)] if ycols.nil? or ycols.empty?
              ncols = Arraynge.ml_arraynge(num_cols,ncols)
              ycols = Arraynge.ml_arraynge(num_cols,ycols)
              #p "ccf: ncols=#{ncols.inspect} ycols=#{ycols.inspect}"
              cx['csv_columns'] = Arraynge.ml_diff(ycols,ncols)
            end
          end
          def _calc_csv_columns(num_cols)
            require 'rio/arraynge'
            ycols = cx['col_args']
            ncols = cx['nocol_args']
            if ncols and ncols.empty?
              cx['csv_columns'] = []
            elsif ycols.nil? and ncols.nil?
              cx['csv_columns'] = nil
            else
              ncols = [] if ncols.nil?
              ycols = [(0..-1)] if ycols.nil? or ycols.empty?
              ncols = Arraynge.ml_arraynge(num_cols,ncols)
              ycols = Arraynge.ml_arraynge(num_cols,ycols)
              #p "ccc: ncols=#{ncols.inspect} ycols=#{ycols.inspect}"
              cx['csv_columns'] = Arraynge.ml_diff(ycols,ncols)
            end
          end
          def _trim(fields)
            _calc_csv_columns(fields.size-1)

            return fields if cx['csv_columns'].nil?
            case fields
            when ::CSV::Row
              fields.fields(*cx['csv_columns'])
            else
              cx['csv_columns'].map{|idx| fields[idx]}.flatten
            end
          end
          def _trim_row(row)
            #p "ncols=#{cx['nocol_args'].inspect} ycols=#{cx['col_args'].inspect}"
            # unless cx['fields_args'].nil?
#               ftc = _fields_to_columns(row,cx['fields_args'])
#               p "ftc=#{ftc.inspect}"
#               unless ftc.empty?
#                 cx['csv_columns'] ||= []
#                 cx['csv_columns'] += ftc
#               end
#             end
#             p "csv_columns=#{cx['csv_columns'].inspect}"

            _calc_csv_fields(row)
            return row if cx['csv_columns'].nil?

            #cols = _trim_col(row.size-1,cx['csv_columns'])
            cols = cx['csv_columns']
            case row
            when ::CSV::Row
              hdrs = cols.map{|idx| row.headers[idx]}.flatten
              flds = cols.empty? ? [] : row.fields(*cols)
              row.class.new(hdrs,flds,row.header_row?)
            else
              flds = cols.map{|idx| row[idx]}.flatten
              ::CSV::Row.new([],flds)
            end
          end
          def _trim_col(mx,cols)
            cols.map do |el|
              (el.is_a?(::Range) and el.max > mx ? el.min..mx : el)
            end
          end
          def _fields_to_columns(row,flds)
            cols = []
            flds.each do |fld|
              case fld
              when Range
                ibeg = fld.begin.is_a?(Integer) ? fld.begin : row.index(fld.begin)
                iend = fld.end.is_a?(Integer) ? fld.end : row.index(fld.end)
                rng = fld.exclude_end? ? (ibeg...iend) : (ibeg..iend)
                cols << rng
              when Integer
                cols << fld
              else
                cols << row.index(fld)
              end
            end
            cols.flatten
          end


          def each_line(*args,&block)
            # p self
            while raw_rec = self.shift()
              # p "RAW_REC=#{raw_rec}"
              case cx['stream_itertype']
              when 'lines' 
                yield _trim(raw_rec).to_csv(*cx['csv_args'])
              when 'records'
                case raw_rec
                when ::Array then yield _trim(raw_rec)
                else yield _trim(raw_rec.fields)
                end
              when 'rows'
                yield _trim_row(raw_rec)
              else
                yield _trim(raw_rec)
              end
            end
          end


          def each_line0(*args,&block)
            self.each(*args) do |raw_rec|
              case cx['stream_itertype']
              when 'lines' 
                yield _trim(raw_rec).to_csv(*cx['csv_args'])
              when 'records'
                case raw_rec
                when ::Array then yield _trim(raw_rec)
                else yield _trim(raw_rec.fields)
                end
              when 'rows'
                yield _trim_row(raw_rec)
              else
                yield _trim(raw_rec)
              end
            end
          end


        end
      end
      module Output
        def add_csv_filter
          #p "add_csv_filter(#{self.ioh.ios})"
          csvio = ::CSV.new(self.ioh.ios,*cx['csv_args'])
          self.ioh.ios = csvio
        end
      end
      module Input
        def add_csv_filter
          begin
          end
          begin
            if cx['headers_args']
              cx['csv_args'][0] ||= {}
              cx['csv_args'][0][:headers] = cx['headers_args']
            else
              if cx['stream_itertype'] == 'rows'
                cx['csv_args'][0] ||= {}
                cx['csv_args'][0][:headers] = true
                #cx['csv_args'][0][:return_headers] = true
              end
            end
          end
          csvio = ::CSV.new(self.ioh.ios.binmode,*cx['csv_args'])
          csvio.extend Filter::CSVMissing
          csvio.set_cx(cx)
          self.ioh.ios = csvio
        end
      end
    end
  end
end

__END__
