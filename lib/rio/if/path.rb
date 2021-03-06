# -*- coding: utf-8 -*-
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
module RIO
  module IF
    module Path

      
      # Returns the path for the Rio, which is defined differently for different types of Rios.
      #
      # For Rios representing paths on the underlying file system this is an alias 
      # {#fspath}[rdoc-ref:IF::Path#fspath]. For Rios with paths that are not on the file system this is an
      # alias for {#urlpath}[rdoc-ref:IF::Path#urlpath].
      # 
      # Otherwise this returns nil.
      # 
      def path(*args) target.path(*args) end
      
      # For resources that have a absolute URL (RFC1738) representation, 
      # this returns a string containing that representation. 
      # For objects that do not this returns a RIORL (a descriptive pseudo-URL).
      #
      #  rio('/var/www/')                  #=> "file:///var/www/"
      #  rio('http://rio.rubyforge.org/')  #=> "http://rio.rubyforge.org"
      #  
      def to_url() target.to_url end

      # For resources that have a URL (RFC1738) representation, this returns a 
      # URI object referencing it.  Otherwise this raises NoMethodError.
      #
      #  rio('http://rubyforge.org/').to_uri     #=> <URI::HTTP:0x818bd84 URL:http://rubyforge.org/>
      #  rio('adir/afile').to_uri                #=> <URI::Generic:0x817d288 URL:adir/afile>
      #
      def to_uri() target.to_uri end

      # Returns the path for the Rio on the underlying file system
      # Returns nil if the Rio is not on the filesystem (i.e. stdin: or http: Rios)
      def fspath() target.fspath() end

      # Returns the path portion of the URL representation of the rio 
      # Returns nil if the Rio URL has no path (i.e. stdin: or http: Rios)
      def urlpath() target.urlpath() end

      # Calls File#expand_path
      #
      #
      # Converts a pathname to an absolute pathname. 
      # Relative paths are referenced from the current working directory of the process 
      # unless dir_string is given, in which case it will be used as the starting point. 
      # The given pathname may start with a ``~��, which expands to the process owner�s 
      # home directory (the environment variable HOME must be set correctly). 
      # ``~user�� expands to the named user�s home directory.
      #
      # Returns a Rio representing the returned path
      #
      # 
      def expand_path(*args) target.expand_path(*args) end


      # Returns a new rio with a path equal to the absolute path of this rio
      #
      #  rio('/tmp').chdir
      #  rio('afile').abs # => rio('/tmp/afile')
      def abs(*args) target.abs(*args)  end


      # Returns a new rio with a path equal to the relative path from _other_
      #  rio('/tmp/afile').rel('/tmp')   #=> rio('afile')
      #  rio('zippy/afile').rel('zippy') #=> rio('afile')
      #
      def rel(other=nil) target.rel(other)  end


      # Returns a new Rio whose path is the base path that is used by 
      # {#abs}[rdoc-ref:IF::Path#abs] to create an absolute Rio from a relative one.
      #
      #  rio('/tmp').chdir
      #  rio('afile').base # => rio('/tmp/')
      #
      # See {#abs}[rdoc-ref:IF::Path#abs].
      #
      def base() target.base()  end


      # Sets the string that the Rio considers an extension. The value will be used by
      # subsequent calls to {#basename}[rdoc-ref:IF::Path#basename]. If called with no arguments resets its value
      # to the value returned by File#extname. Returns the Rio.
      #
      #  ario = rio('afile.tar.gz')
      #  ario.ext?                        #=> '.gz'
      #  ario.basename                    #=> rio('afile.tar')
      #  ario.ext('.tar.gz').basename     #=> rio('afile')
      #  ario.ext?                        #=> '.tar.gz'
      #
      #  ario = rio('afile.txt')
      #  ario.ext('.txt').basename        #=> rio('afile')
      #  ario.ext('.zip').basename        #=> rio('afile.txt')
      #  ario.ext.basename                #=> rio('afile')
      #  ario.ext('').basename            #=> rio('afile.txt')
      #
      # See also {#ext?}[rdoc-ref:IF::Path#ext?],{#noext}[rdoc-ref:IF::Path#noext],{#basename}[rdoc-ref:IF::Path#basename],
      #
      def ext(arg=nil) target.ext(arg); self end


      # Identical to {#ext}[rdoc-ref:IF::Path#ext]('')
      #
      #  ario.basename                  #=> rio('afile')
      #  ario.noext.basename            #=> rio('afile.txt')
      #
      # See also {#ext}[rdoc-ref:IF::Path#ext]
      #
      def noext() target.noext(); self end


      # Returns the value of the Rio's 'ext' variable
      # This defaults to the value returned by {#extname}[rdoc-ref:IF::Path#extname] and may be set by either calling {#ext}[rdoc-ref:IF::Path#ext] 
      # or by passing an argument {#basename}[rdoc-ref:IF::Path#basename]
      # See also {#basename}[rdoc-ref:IF::Path#basename], {#ext}[rdoc-ref:IF::Path#ext], {#extname}[rdoc-ref:IF::Path#extname], {#noext}[rdoc-ref:IF::Path#noext]
      #
      #  ario = rio('afile.txt')
      #  ario.ext?                        #=> '.txt'
      #  ario.ext('.txt').basename        #=> rio('afile')
      #  ario.ext?                        #=> '.txt'
      #  ario.ext('.zip').basename        #=> rio('afile.txt')
      #  ario.ext?                        #=> '.zip'
      #  ario.basename('.tar')            #=> rio('afile.txt')
      #  ario.ext?                        #=> '.tar'
      #  ario.ext.basename                #=> rio('afile')
      #  ario.ext?                        #=> '.txt'
      #  ario.noext.basename              #=> rio('afile.txt')
      #  ario.ext?                        #=> ''
      #
      def ext?() target.ext?() end


      # Calls File#extname
      #
      # Returns a String containing the path's extension
      #    rio('/tmp/zippy.txt').extname   #=> '.txt'
      #
      def extname(*args) target.extname(*args) end


      # Similar to File#basename
      #
      # Returns a Rio whose path is that returned by File#basename when passed the path
      # of a rio and the value returned by File#extname. This differs from the behaviour
      # of File#basename.
      #
      #  File.basename('afile.txt')                           #=> 'afile.txt'
      #  File.basename('afile.txt',File.extname('afile.txt')) #=> 'afile'
      #  rio('afile.txt').basename                            #=> rio('afile')
      #  rio('afile.txt').basename('.txt')                    #=> same thing
      #  rio('afile.txt').ext('.txt').basename                #=> same thing
      #
      # See also {#ext}[rdoc-ref:IF::Path#ext],{#ext?}[rdoc-ref:IF::Path#ext?],{#filename}[rdoc-ref:IF::Path#filename],
      #
      def basename(*args) target.basename(*args) end


      # Calls File#dirname
      #
      # Returns a new Rio referencing the directory portion of a Rio.
      #    rio('/tmp/zippy.txt').dirname   #=> rio('/tmp')
      #
      def dirname(*args) target.dirname(*args) end


      # Returns a new Rio with all path information stripped away. This is similar to
      # {#basename}[rdoc-ref:IF::Path#basename], except that it always includes an extension if one exists
      #
      #  rio('apath/afile.txt').filename #=> rio('afile.txt')
      #
      def filename() target.filename() end


      # Replace the part of the path returned by {#extname}[rdoc-ref:IF::Path#extname]. If in +rename+
      # mode, also renames the referenced filesystem object.
      #
      # Returns the extension
      #
      #   ario = rio('dirA/dirB/afile.rb')
      #   ario.extname = '.txt'          # rio('dirC/bfile.txt')
      #
      #   rio('adir/afile.txt').rename.extname  = '.rb'      # adir/afile.txt => adir/afile.rb
      #
      # See aslo {#extname}[rdoc-ref:IF::Path#extname], {#rename}[rdoc-ref:IF::FileOrDir#rename]
      #
      def extname=(arg) target.extname = arg end


      # Replace the part of the path returned by {#basename}[rdoc-ref:IF::Path#basename]. If in +rename+
      # mode, also renames the referenced filesystem object.
      # 
      # Returns the new value of +basename+
      #
      #   ario = rio('dirA/dirB/afile.rb')
      #   ario.dirname = 'dirC'          # rio('dirC/afile.rb')
      #   ario.basename = 'bfile'        # rio('dirC/bfile.rb')
      #   ario.extname = '.txt'          # rio('dirC/bfile.txt')
      #   ario.filename = 'cfile.rb'     # rio('dirC/cfile.rb')
      #
      #   rio('adir/afile.txt').rename.filename = 'bfile.rb' # adir/afile.txt => adir/bfile.rb
      #   rio('adir/afile.txt').rename.basename = 'bfile'    # adir/afile.txt => adir/bfile.txt
      #   rio('adir/afile.txt').rename.extname  = '.rb'      # adir/afile.txt => adir/afile.rb
      #   rio('adir/afile.txt').rename.dirname =  'b/c'      # adir/afile.txt => b/c/afile.txt
      #
      # See {#basename}[rdoc-ref:IF::Path#basename], {#rename}[rdoc-ref:IF::FileOrDir#rename]
      #
      def basename=(arg) target.basename = arg end


      # Replace the part of the path returned by {#dirname}[rdoc-ref:IF::Path#dirname]. If in +rename+
      # mode, also renames the referenced filesystem object.
      # 
      # Returns the new value of +dirname+
      #
      #   ario = rio('dirA/dirB/afile.rb')
      #   ario.dirname = 'dirC'          # rio('dirC/afile.rb')
      #   ario.basename = 'bfile'        # rio('dirC/bfile.rb')
      #   ario.extname = '.txt'          # rio('dirC/bfile.txt')
      #   ario.filename = 'cfile.rb'     # rio('dirC/cfile.rb')
      #
      #   rio('adir/afile.txt').rename.filename = 'bfile.rb' # adir/afile.txt => adir/bfile.rb
      #   rio('adir/afile.txt').rename.basename = 'bfile'    # adir/afile.txt => adir/bfile.txt
      #   rio('adir/afile.txt').rename.extname  = '.rb'      # adir/afile.txt => adir/afile.rb
      #   rio('adir/afile.txt').rename.dirname =  'b/c'      # adir/afile.txt => b/c/afile.txt
      #
      # See {#dirname}[rdoc-ref:IF::Path#dirname], {#rename}[rdoc-ref:IF::FileOrDir#rename]
      #
      def dirname=(arg) target.dirname  = arg end



      # Replace the part of the path returned by {#filename}[rdoc-ref:IF::Path#filename]. If in +rename+
      # mode, also renames the referenced filesystem object.
      # 
      # Returns the new value of +filename+
      #
      #   ario = rio('dirA/dirB/afile.rb')
      #   ario.dirname = 'dirC'          # rio('dirC/afile.rb')
      #   ario.basename = 'bfile'        # rio('dirC/bfile.rb')
      #   ario.extname = '.txt'          # rio('dirC/bfile.txt')
      #   ario.filename = 'cfile.rb'     # rio('dirC/cfile.rb')
      #
      #   rio('adir/afile.txt').rename.filename = 'bfile.rb' # adir/afile.txt => adir/bfile.rb
      #   rio('adir/afile.txt').rename.basename = 'bfile'    # adir/afile.txt => adir/bfile.txt
      #   rio('adir/afile.txt').rename.extname  = '.rb'      # adir/afile.txt => adir/afile.rb
      #   rio('adir/afile.txt').rename.dirname =  'b/c'      # adir/afile.txt => b/c/afile.txt
      #
      # See {#filename}[rdoc-ref:IF::Path#filename], {#rename}[rdoc-ref:IF::FileOrDir#rename]
      #
      def filename=(arg) target.filename = arg end


      # Creates new Rio by adding args as additional directory components like File#join.
      #
      #   ario = rio('adir')
      #   brio = rio('b')
      #   crio = ario.join(brio)    #=> rio('adir/b')
      #
      #   ario = rio('adir')
      #   ario.join('b','c','d')    #=> rio('ario/b/c/d')
      #
      # See also IF::Path#/
      def join(*args) target.join(*args) end


      # Returns an array of Rios, one for each path element. 
      # (Note that this behavior differs from File#split.)
      #
      #  rio('a/b/c').split   #=> [rio('a'),rio('b'),rio('c')]
      #
      # The array returned is extended with a +to_rio+ method, 
      # which will put the parts back together again.
      #
      #  ary = rio('a/b/c').split   #=> [rio('a'),rio('b'),rio('c')]
      #  ary.to_rio           #=> rio('a/b/c')
      #
      #  ary = rio('a/b/c').split   #=> [rio('a'),rio('b'),rio('c')]
      #  ary[1] = rio('d')
      #  ary.to_rio           #=> rio('a/d/c')
      #
      # See also {#join}[rdoc-ref:IF::Path#join], IF::Path#/
      #
      def splitpath() target.splitpath() end


      # Subdirectory operator.
      #
      # Effectively the same as {#join}[rdoc-ref:IF::Path#join](arg)
      #
      #   a = rio('a')
      #   b = rio('b')
      #   c = a/b                   #=> rio('a/b')
      #
      #   ario = rio('adir')
      #   ario/'afile.rb'           #=> rio('adir/afile.rb')
      #   ario/'b'/'c'/'d'          #=> rio('adir/b/c/d')
      #   
      #   ario = rio('adir')
      #   ario /= 'afile.rb'        #=> rio('adir/afile.rb')
      #   
      def /(arg) 
        target / arg 
      end


      # Rio#catpath!
      #
      #
      #def catpath!(*args) target.catpath!(*args); self end


      # Rio#catpath
      #
      #
      #def catpath(*args) target.catpath(*args) end


      # Changes a Rio inplace by adding args as additional directory components like {#join}[rdoc-ref:IF::Path#join],
      #
      def join!(*args) target.join!(*args); self end

      # {#rootpath}[rdoc-ref:IF::GrandeStream#rootpath]
      #
      #
      def rootpath(*args) # :nodoc:
        target.rootpath(*args) 
      end


      # {#root}[rdoc-ref:IF::GrandeStream#root]
      #
      #
      ##def root(*args,&block) target.root(*args,&block) end


      # Rio#cwd
      #
      #
      ##def cwd(*args,&block) target.cwd(*args,&block) end


      # {#getwd}[rdoc-ref:IF::Grande#getwd]
      #
      #
      ##def getwd(*args,&block) target.getwd(*args,&block) end


      # Returns the scheme for the Rio's URI-like URI#scheme where the Rio is represented
      # by a standard URI. For Rios that are not represented by standard URIs one of
      # Rio's non-standard schemes is returned. 
      #
      #  rio('http://ruby-doc.org/').scheme #=> 'http'
      #
      def scheme(*args) target.scheme(*args) end

      # Calls URI#host for Rios which have a URI. Otherwise raises NoMethodError.
      #
      #  rio('http://ruby-doc.org/').host #=> 'ruby-doc'
      #
      def host(*args) target.host(*args) end

      # Calls URI#opaque for Rios which have URI representations. The opaque portion
      # of a URI is the portion after the colon and before the question-mark beginning 
      # the query.
      #
      #  rio('http://example.org/do.cgi?n=1').opaque  #=> '//example.org/do.cgi'
      #
      # For Rios that do not have URL representations, returns the same part of 
      # Rio's internal psuedo-URL
      def opaque(*args) target.opaque(*args) end



      # Calls URI#merge
      # 
      # Merges two Rios. URI#merge does not document exactly what merging two URIs means. 
      # This appears to join the paths like <tt>other + path</tt>. 
      # See URI#merge for less information.
      #
      def merge(other) target.merge(other)  end


      # Calls URI#route_from
      #
      # Returns a new rio representing the path to this Rio from the perspective of _other_.
      # URI#route_from requires that absolute URIs be used. {#route_from}[rdoc-ref:IF::Path#route_from] does not.
      #
      def route_from(other) target.route_from(other)  end

      # Calls URI#route_to
      #
      # Returns a new rio representing the path to _other_ from the perspective of this Rio.
      # URI#route_to requires that absolute URIs be used. {#route_to}[rdoc-ref:IF::Path#route_to] does not.
      #
      def route_to(other) target.route_to(other)  end

      # Calls Pathname#cleanpath
      #
      # Returns a new Rio whose path is the clean pathname of +self+ with 
      # consecutive slashes and useless dots
      # removed.  The filesystem is not accessed.
      #
      # If +consider_symlink+ is +true+, then a more conservative algorithm is used
      # to avoid breaking symbolic linkages.  This may retain more <tt>..</tt>
      # entries than absolutely necessary, but without accessing the filesystem,
      # this can't be avoided.  See #realpath.
      #
      def cleanpath(consider_symlink=false) target.cleanpath(consider_symlink)  end

      # Calls Pathname#realpath
      #
      # Returns a new Rio whose path is the real (absolute) pathname 
      # of +self+ in the actual filesystem.
      # The real pathname doesn't contain symlinks or useless dots.
      #
      def realpath() target.realpath()  end
      
    end
  end
end
module RIO
  class Rio
    include RIO::IF::Path
  end
end
