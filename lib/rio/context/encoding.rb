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


require 'rio/context/cxx.rb'

module RIO
  module Cx #:nodoc: all

    module Methods
      def enc(*args,&block) 
        #ioh.set_encoding(*args) if ioh
        _set_enc_from_args(*args)
        cxx(:enc_args,args,&block) 
      end
      def int_enc?()
        ioh ? ioh.internal_encoding : cx[:enc_int]
      end
      def ext_enc?()
        ioh ? ioh.external_encoding : cx[:enc_ext]
      end
      def enc_opts?()
        cx[:enc_opts]
      end
      def enc?() 
        setting = cxx?(:enc_args)
        #unless ioh.nil?
        #  actual = [ioh.
        #  cxx_(actual) unless actual == setting
        #end
        setting
      end 

      protected

      def enc_(*args)  
        cxx_('enc_args',arg) 
      end

      private

      def _set_enc_from_args(*args)
        arg0 = args.shift
        bargs = []
        if arg0.is_a?(::String) and i = arg0.index(':')
          bargs << arg0[0..i] << arg0[i+1..-1]
        else
          bargs << arg0
        end
        bargs += args
        ext_enc = bargs.shift
        int_enc = bargs.shift
        opts = bargs.shift
        cx[:enc_ext] = ext_enc if ext_enc
        cx[:enc_int] = int_enc if int_enc
        cx[:enc_opts] = opts if opts
      end

    end


  end
end
