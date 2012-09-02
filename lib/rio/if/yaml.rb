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
  module IF
    module YAML
      #def file() target.file end
      #def dir() target.dir end
      
      # Puts a Rio in YAML mode.
      #
      #
      # Rio uses the YAML class from the Ruby standard library to provide
      # support for reading and writing YAML files. Normally using
      # <tt>(skip)records</tt> is identical to <tt>(skip)lines</tt> because
      # while +records+ only selects and does not specify the record-type,
      # +lines+ is the default.
      #
      # The YAML extension distingishes between items selected using
      # {#records}[rdoc-ref:IF::GrandeStream#records], {#rows}[rdoc-ref:IF::GrandeStream#rows] and {#lines}[rdoc-ref:IF::GrandeStream#lines]. 
      # Rio returns objects loaded via
      # YAML#load when +records+ or #objects is used; returns the YAML text as a String
      # when +rows+ or #documents is used; and returns lines as Strings as normal when
      # +lines+ is used.  +records+ is the default. 
      #
      # To read a single YAML document, Rio provides #getobj and #load. For
      # example, consider the following partial 'database.yml' from the rails
      # distribution:
      #
      #  development:
      #    adapter: mysql
      #    database: rails_development
      #
      #  test:
      #    adapter: mysql
      #    database: rails_test
      #
      #
      # To get the object represented in the yaml file:
      #
      #  rio('database.yml').yaml.load
      #     ==>{"development"=>{"adapter"=>"mysql", "database"=>"rails_development"}, 
      #         "test"=>{"adapter"=>"mysql", "database"=>"rails_test"}}
      #
      # Or one could read parts of the file like so:
      #
      #  rio('database.yml').yaml.getobj['development']['database']
      #     ==>"rails_development"
      #
      # Single objects can be written using #putobj and #putobj!
      # which is aliased to #dump
      #
      #  anobject = {
      #    'production' => {
      #      'adapter' => 'mysql',
      #      'database' => 'rails_production',
      #    }
      #  }
      #  rio('afile.yaml').yaml.dump(anobject)
      #
      #
      # Single objects can be written using {#putrec}[rdoc-ref:IF::GrandeStream#putrec] (aliased to {#putobj}[rdoc-ref:IF::YAML#putobj]
      # and {#dump}[rdoc-ref:IF::YAML#dump])
      #
      #  rio('afile.yaml').yaml.putobj(anobject)
      #
      # Single objects can be loaded using {#getrec}[rdoc-ref:IF::GrandeStream#getrec] (aliased to {#getobj}[rdoc-ref:IF::YAML#getobj]
      # and {#load}[rdoc-ref:IF::YAML#load])
      #
      #  anobject = rio('afile.yaml').yaml.getobj
      #
      # A Rio in yaml-mode is just
      # like any other Rio. And all the things you can do with any Rio come
      # for free.  They can be iterated over using {#each}[rdoc-ref:IF::Grande#each] and read into an
      # array using {#[]}[link:RIO/IF/Grande.html#method-i-5B-5D] just like any other Rio. All the selection criteria
      # are identical also.
      #
      # Get the first three objects into an array:
      #
      #  array_of_objects = rio('afile.yaml').yaml[0..2]
      #
      # Iterate over only YAML documents that are a kind_of ::Hash:
      #
      #  rio('afile.yaml').yaml(::Hash) {|ahash| ...} 
      #
      # This takes advantage of the fact that the default for matching records
      # is <tt>===</tt>
      #
      # Selecting records using a Proc can be used as normal:
      #
      #  anarray = rio('afile.yaml').yaml(proc{|anobject| ...}).to_a
      #
      # One could even use the copy operator to convert a CSV file to a YAML
      # representation of the same data:
      #
      #  rio('afile.yaml').yaml < rio('afile.csv').csv 
      #
      def yaml(&block) 
        target.yaml(&block); 
        self 
      end


      # Queries if the Rio is in yaml-mode. See #yaml
      def yaml?() target.yaml? end


      # Select objects from a YAML file. See #yaml and RIO::Doc::INTRO
      def objects(*selectors,&block) target.objects(*selectors,&block); self end


      # Reject objects from a YAML file. Calls {#skiprecords}[rdoc-ref:IF::GrandeStream#skiprecords]. See #yaml and RIO::Doc::INTRO
      def skipobjects(*selectors,&block) target.skipobjects(*selectors,&block); self end


      # Select documents from a YAML file. See #yaml and RIO::Doc::INTRO
      def documents(*selectors,&block) target.documents(*selectors,&block); self end


      # Reject documents from a YAML file. Calls {#skiprows}[rdoc-ref:IF::GrandeStream#skiprows]. See #yaml and RIO::Doc::INTRO
      def skipdocuments(*selectors,&block) target.skipdocuments(*selectors,&block); self end

      # Select a single object. See #objects, {#line}[rdoc-ref:IF::GrandeStream#line] and #yaml.
      def object(*args,&block) target.object(*args,&block); self end


      # Select a single yaml document. See #documents, {#line}[rdoc-ref:IF::GrandeStream#line] and #yaml.
      def document(*args,&block) target.document(*args,&block); self end
      

      # Calls YAML.load.
      #
      # Loads a single YAML object from the stream referenced by the Rio
      #
      #   rio('database.yml').yaml.getobj
      #
      # See #yaml and RIO::Doc::INTRO
      #
      def getobj() target.getobj() end

      # Calls YAML.load.
      #
      # Loads a single YAML object from the stream referenced by the Rio
      #
      #   rio('database.yml').yaml.load
      #
      # See #yaml and RIO::Doc::INTRO
      #
      def load() target.load() end

      # Alias for #getrec
      #def getdoc() target.getdoc() end


      # Calls YAML.dump, leaving the Rio open.
      def putobj(obj) target.putobj(obj); self end

      # Dumps an object to a Rio as with {#putobj}[rdoc-ref:IF::YAML#putobj], and closes the Rio.
      #
      #  rio('afile.yaml').yaml.putobj!(anobject)
      #
      # is identical to 
      #
      #  rio('afile.yaml').yaml.putobj(anobject).close
      #
      def putobj!(obj) target.putobj!(obj); self end

      # Alias for {#putobj!}[rdoc-ref:IF::YAML#putobj!]
      def dump(obj) target.dump(obj); self end

    end
  end
end
