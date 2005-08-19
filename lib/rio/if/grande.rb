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


module RIO
  class Rio
    # Returns the contents of the rio as an array.
    # Rio#to_a is implemented in terms of Rio#each so the the following are roughly equivelent
    #
    #  ary = ario.to_a
    #
    #  ary = []
    #  ario.each do |rec|
    #    ary << ary
    #  end
    #
    # What constitutes an array element is determined by Rio#lines, Rio#bytes, or 
    # by an extension such as Rio#csv. Rio#lines is the default.
    #
    #  rio('afile.txt').to_a # returns an array of the lines in afile.txt
    #
    #  rio('afile.txt').lines(1...3).to_a # an array containing lines 1 and 2 of afile.txt
    # 
    #  rio('afile.dat').bytes(50).to_a # an array containing the contents of afile.dat broken 
    #                                  # up into 50 byte chunks
    #
    # See also Rio#[] (subscript operator)
    #
#    def to_a() target.to_a() end

    # Grande subscript operator. 
    # 
    # For files this returns all or part of a file as an array.
    #
    # For directories this returns all or some of the entries in a directory
    #
    # === Files
    #
    # This combines the record selection offered by Rio#records with
    # the conversion to an array provided by Rio#to_a. The following two are equivelant:
    # * ario[*args]
    # * ario.records(*args).to_a
    #
    # What constitutes an array element is determined by Rio#lines, Rio#bytes, 
    # or by an extension such as Rio#csv. Rio#lines is the default.
    # 
    # Arguments may consist of zero or more integers, ranges, regular expressions, symbols
    # and procs. 
    # An empty argument list selects all records
    #
    # Records are selected as follows.
    # range::   specifies a range of records to be selected (zero based)
    # regexp::  matching records will be selected.
    # integer:: treated like a one element range
    # symbol::  the symbol is sent to the string. record is selected unless false is returned
    # proc::    the proc is called with the string as an argument. record is selected unless false is returned
    # 
    # A record matching *any* of the selectors will be included in the array. (acts like an _or_)
    #
    # Because this is implemented in terms of the Rio#each, 
    # When only record ranges are used to select records,
    # iteration will stop when the recno exceeds the maximum of any range. That is to say
    #
    # This reads one record from a file and returns it
    #  rio('bigfile.mp3').bytes(1024)[0]
    # While this reads *all* records from a file and returns the first one
    #  rio('bigfile.mp3').bytes(1024).to_a[0]
    # 
    # === Directories
    # 
    # This combines the entry selection offered by Rio#entries with
    # the conversion to an array provided by Rio#to_a. The following two are equivelant:
    # * ario[*args]
    # * ario.entries(*args).to_a
    #
    # Arguments may consist of strings (treated as globs) or regular expressions. 
    # An empty argument list selects all entries
    # See ::Dir#glob and ::File::fnmatch? for more in information on _globs_. Be warned that using the '**' glob
    # recurses into directories independently of Rio#all and using both is unsupported.
    # 
    #  ario = rio('adir')
    #  ario[] # returns an array containg all entries in _adir_
    #  ario[/^zippy/] # all entries starting with 'zippy'
    #  ario['zippy*'] # same thing
    #
    # As with Rio#each:
    # * Files and directories are returned as Rios
    # * The types of entries is also affected by Rio#files and Rio#dirs.
    #    rio('adir').files['*.txt'] # array of all _.txt_ files
    #    rio('adir').dirs(/^\./) # array of all dot directories
    # * Recursion is enabled using Rio#all
    #    rio('adir').all.files['*.[ch]'] # array of c source files in _adir_ and its subdirecories
    #    rio('adir').all.dirs[/^\.svn/]  # array of subversion directories in _adir_ and subdirectories
    # * Rio#files and Rio#dirs act independetly of each other. Specifying both will cause both to be returned. 
    #   The argument list to Rio#[] will be applied to the closest.
    #    rio('adir').files('*.rb').dirs['ruby*'] # array of _.rb_ files and 
    #                                            # directories starting with 'ruby'
    #    rio('adir').dirs('ruby*').files['*.rb'] # same thing
    #
    # === Lines
    # This section applies similarly to Rio#lines, Rio#bytes, Rio#records, and Rio#rows
    #
    # Using Rio#lines and related methods with a Rio referencing a directory 
    # imples Rio#files and will cause an array of the lines or bytes in the files to be returned. As above,
    # the arguments to the subscript operator will be applied to the closest.
    #  rio('adir').lines[] # array of all lines in the files in 'adir'
    #  rio('adir').files.lines[] # same thing
    #  rio('adir').lines(0..9).files['*.txt'] # array of the first ten lines of all .txt files
    #  rio('adir').files('*.txt').lines[0..9] # same thing
    #  rio('adir').all.files('*.rb').lines[/^\s*require/] # array of 'require' lines in .rb files in
    #                                                     # 'adir and its subdirectories
    #
    # Note the difference between the following similar usages
    #  it1 = rio('adir').files('*.rb') # returns a Rio, prepared for selecting ruby files
    #  it2 = rio('adir').files['*.rb'] # returns an array of the ruby files
    #
    # The second example above could have been written
    #  it2 = it1.to_a
    #
    # Examples:
    #
    #  rio('afile.txt').lines[1..2] # array containing the 2nd and 3rd line
    # 
    #  rio('afile.txt')[1,3..5] # array containing lines 1,3,4 and 5
    # 
    #  rio('afile.txt')[/Zippy/] # array of all lines containing 'Zippy'
    # 
    #  rio('afile.txt')[1,3..5,/Zippy/] # array with lines 1,3,4 and 5 and all lines containing 'Zippy'
    # 
    #  rio('afile.dat').bytes(50)[] # array containing the contents of afile.dat broken up into 50 byte chunks
    #
    #  rio('afile.dat').bytes(50)[0,2] # array containing the first and third such chunk
    #  
    #  rio('afile.dat').bytes(50).records[0,2] # same thing
    #  
    #  rio('afile.dat').bytes(50).records(0,2).to_a # once again
    #
    #  rio('afile.csv').csv[0..9] # array of the first 10 records of afile.csv parsed by the ::CSV module
    #
    #  rio('afile.csv').csv.records[0..9] # same thing
    #
    #  rio('afile.csv').csv(';').records[0..9] # same thing using semi-colon as the value separator
    #  
    #  rio('afile.csv').csv.records[0,/Zippy/] # record 0 and all records containing 'Zippy'
    #                                          # the regexp is matched against the line before parsing by ::CSV
    #
    #  rio('adir')[] # array of entries in 'adir'
    #
    #  rio('adir')['*.txt'] # array of all .txt entries
    # 
    #  rio('adir').all['*.txt'] # array of all .txt entries in 'adir and its subdirectories
    #
    #  rio('adir').files['*.txt'] # array of all .txt files
    #
    #  rio('adir').dirs['CSV'] # array of all CSV directories
    #  rio('adir').nodirs['CSV'] # array of all non-CSV directories
    #
    def [](*selectors) target[*selectors] end



    # Iterate through a rio. Executes the block for each item selected for the Rio. 
    # See Rio#lines, Rio#records, Rio#bytes, Rio#files, Rio#dirs, Rio#[] 
    # and Rio#to_a for more information
    # on how records are selected and what kind of record is passed to the block.
    # 
    # Rio#each is the fundemental method for all the Rio grande operators.
    # Rio#to_a and the Rio copy operators Rio#< Rio#<< Rio#>> Rio#> are all implemented 
    # in terms of Rio#each.
    #
    # While Rio#each is fundamental to a Rio, it rarely needs 
    # actually be called because all the grande configuration methods will also take a block 
    # and call Rio#each if one is given. 
    # So the existance of a block after many methods is taken as an implied
    # Rio#each
    #
    # For Rios that refer to files, the item passed to the block is a String containing
    # the line or block as selected by Rio#lines, or Rio#bytes. +lines+ is the default.
    #  rio('afile').lines.each { |line| ...}
    # 
    # The block passed to +each+ will also accept an optional second parameter which will contain
    # the result of the matching function. What this variable contains depends on the argument
    # to +lines+ that resulted in the match as follows:
    # 
    # Regexp::   The MatchData that resulted from the match.
    # Range::    The record number of the matching record.
    # Fixnum::   The record number of the matching record.
    # Proc::     The value returned by the proc.
    # Symbol::   The value resulting from sending the symbol to the String.
    #
    # If no selection arguments were used, this variable will simply contain +true+.
    #
    #  rio(??).puts(%w[0:zero 1:one]).rewind.lines(/(\d+):([a-z]+)/) do |line,match| 
    #    puts("#{match[1]} is spelled '#{match[2]}'")
    #  end
    # 
    # Produces:
    #  0 is spelled 'zero'
    #  1 is spelled 'one'
    #
    # 
    # For Rios that refer to directories, the item passed to the block is a Rio refering to
    # the directory entry. 
    #
    #  rio('adir').files.each do |file|
    #    file.kind_of?(RIO::Rio)  # true
    #  end
    # 
    # In addition, the Rio passed to the block inherits certain attributes from the directory Rio.
    #
    #  rio('adir').files.chomp.each do |file| # chomp is ignored for directories,
    #    file.each do |line|                  # chomp attribute is inherited by the file rio
    #      # .. line is chomped
    #    end
    #  end
    #
    # Rio#each returns the Rio which called it.
    #
    # Here are a few illustrative examples
    # 
    # * Processing lines in a file
    #
    #    rio('f.txt').each { |line| ... }        # execute block for every line in the file
    #    rio('f.txt').lines.each { |line| ... }  # same thing
    #    rio('f.txt').lines { |line| ... }       # same thing
    #
    #    rio('f.txt').chomp.each { |line| ... }  # same as above with lines chomped
    #    rio('f.txt').chomp { |line| ... }       # ditto
    #    rio('f.txt').lines.chomp { |line| ... } # ditto
    #    rio('f.txt').chomp.lines { |line| ... } # ditto
    #
    #    rio('f.txt.gz').gzip.each { |line| ... }   # execute block for every line in a gzipped file
    #    rio('f.txt.gz').gzip { |line| ... }        # same thing
    #    rio('f.txt.gz').lines.gzip { |line| ... }  # same thing
    #
    #    rio('f.txt.gz').gzip.chomp { |line| ... } # chomp lines from a gzipped file
    #    rio('f.txt.gz').gzip.chomp.each { |line| ... } # ditto
    #    rio('f.txt.gz').chomp.lines.gzip { |line| ... } # ditto
    #    
    #    rio('f.txt').lines(0..9) { |line| ... } # execute block for the first 10 lines in the file 
    #    rio('f.txt').lines(0..9).each { |line| ... } # same thing
    #
    #    rio('f.txt').lines(/^\s*#/) { |line| ... } # execute block for comment-only lines
    #    rio('f.txt').lines(/^\s*#/).each { |line| ... } # same thing
    #    
    #    rio('f.txt').lines(0,/Rio/) { |line| ... } # execute block for the first line and
    #                                               # all lines containing 'Rio'
    #    
    #    rio('f.txt.gz').gzip.chomp.lines(0..1) { |line| ... } # first 2 lines chomped from a gzip file
    # 
    # * Processing a file a block at a time
    #
    #    rio('f.dat').bytes(10).each { |data| ... } # process the file 10 bytes at a time
    #    rio('f.dat').bytes(10) { |data| ... }      # same thing
    #    rio('f.dat').bytes(10).records(2,4) { |data| ... } # only 3rd and 5th ten-byte data-block
    #    rio('f.dat.gz').gzip.records(2,4).bytes(10) { |data| ... } # same from a gzipped file
    #    
    # * Iterating over directories
    #    rio('adir').each { |ent| ... }       # execute the block for each entry in the directory 'adir'
    #    rio('adir').files.each { |file| ...} # only files
    #    rio('adir').files { |file| ...}      # ditto
    #    rio('adir').all.files { |file| ...}  # files, recurse into subdirectories
    #    rio('adir').dirs { |dir| ...}       # only directories
    #    rio('adir').files('*.rb') { |file| ...}  # only .rb files using a glob
    #    rio('adir').files(/\.rb$/) { |file| ...}  # only .rb files using a regular expression
    #    rio('adir').all.files('*.rb') { |file| ...}  # .rb files, recursing into subdirectories
    #    rio('adir').dirs(/^\./) { |dir| ... } # only dot directories
    #    rio('adir').dirs('/home/*') { |dir| ... } # home directories
    #    
    # See RIO::Doc::HOWTO and RIO::Doc::SYNOPSIS for more examples, and RIO::Doc::INTRO for further explanation.
    #
    def each(*args,&block) target.each(*args,&block); self end


    # For a file Rio +delete+ calls FileUtils#rm. 
    # For a directory Rio +delete+ calls FileUtils#rmdir
    # Returns the Rio. If the Rio does not exist, simply return the Rio.
    #
    #  rio('afile,txt').delete # delete 'afile.txt'
    #  rio('adir').delete # delete adir
    #  rio('something').delete # delete something
    #
    def delete() target.delete(); self end

    # For a file Rio#delete! calls FileUtils#rm. 
    # For a directory Rio#delete! calls FileUtils#rmtree
    # Returns the Rio. If the rio does not exist, simply return itself.
    #
    #  rio('afile,txt').delete! # delete f.txt
    #  rio('adir').delete! # delete adir
    #
    #  # create a directory, after deleting anything that previously had its name
    #  rio('adir/asubdir').delete!.mkpath 
    #
    # ==== Deleting Summary
    # * To delete something only if it is not a directory use Rio#rm
    # * To delete an empty directory use Rio#rmdir
    # * To delete an entire directory tree use Rio#rmtree
    # * To delete anything except a populated directory use Rio#delete
    # * To delete anything use Rio#delete!
    #
    # In all cases, deleting something that does not exist is considered successful
    #
    def delete!() target.delete!(); self end

    # Grande Copy-To Operator
    # 
    # The copy grande-operator copies a Rio to a another Rio or another ruby object. The behaviour 
    # and the library used depend on the types of the of the source and destination. For
    # simple file or directory copying ::FileUtils#cp or ::FileUtils#cp_r will be used. If
    # any of the Rio grande methods are specified for the source or destination, the
    # source Rio will be iterated through copying records to the destintion as specified. Roughly
    # equivelant to
    #  dst = rio('dst_file')
    #  rio('src_file').each do |line|
    #    dst.print(line)
    #  end
    #  dst.close
    #
    # The destination of the copy operators may be a:
    # IO::      Each record of the Rio is written to the IO using IO#print. The IO must be opened for writing.
    # Array::   Each record or entry of the Rio becomes an element of the array
    # String::  Puts the entire contents of the Rio into the string
    # Rio::     Depends on the destination. See below.
    #
    # Copy a file to a file
    #  rio('src_file') > rio('dst_file') 
    # 
    # Copy a file to a directory
    #  rio('src_file') > rio('dst_dir')
    #
    # Copy a directory to another directory
    #  rio('src_dir') > rio('dst_dir')
    #
    # Make an ungizipped copy of a gzipped file
    #  rio('src.txt.gz').gzip > rio('dst.txt')
    #
    # Copying to an array
    #  rio('afile') > ary # each line of the file becomes and element of the ary
    #  rio('afile').chomp > ary # same thing with lines chomped
    #  rio('afile.gz').gzip.chomp > ary # same thing from a gzipped file
    #
    #  rio('afile').lines(0..9) > ary # ary will contain only the first ten lines of the file
    #  rio('afile').chomp.lines(0..9) > ary # same thing with lines chomped
    #  rio('afile').gzip.chomp.lines(0..9) > ary # same thing from a gzipped file
    #
    #  rio('afile').nolines(0..9) > ary # ary will contain all but the first ten lines of the file
    #
    #  rio('adir') > ary # ary will contain a Rio for each entry in the directory
    #  rio('adir').files > ary # same, but only files
    #  rio('adir').files('*.rb') >ary # same, but only .rb files
    # 
    # Copying to a string
    #  rio('afile') > astring # slurp the entire contents of the file into astring
    #  astring = rio('afile').slurp # same effect
    #
    # Copy the first line *and* every line containing the word Rio into a gzipped file
    #  rio('src').lines(1,/Rio/) > rio('dst.gz').gzip
    #
    # Copy lines of a web page into an array with each line chomped
    #  rio('http://ruby-doc.org/index.html').chomp > an_array
    #
    # Copy the first and 8th through 10th columns of the first ten rows of a gzipped csv 
    # file on a web site into a local gzipped csv file that uses semi-colons as separators
    #  rio('http://domain/file.csv.gz').columns(0,7..9).gzip.csv[0..9] > rio('localfile.csv.gz').csv(';').gzip
    #
    def >(destination) target > destination; self end

    # Alias for Rio#> (copy-to grande operator)
    def copy(destination) target.copy(destination); self end

    # Grande Append-To Operator
    # 
    # The append-to grande-operator is the same as Rio#> (copy-to) except that it opens the destination
    # for append.
    # The destination can be a kind of:
    # IO::     Each record of the Rio is written to the IO using IO#print. The IO must be opened for writing.
    # Array::  Each record or entry of the Rio is appended to the destination array
    # String:: Appends the entire contents of the Rio to destination
    # Rio::    Just like Rio#> (copy-to) except the unopened object are 
    #          opened for append. If the destination is already opened for writing or is a 
    #          directory, this is identical to Rio#> (copy-to) 
    #
    # See Rio#> (copy-to)
    # 
    #  rio('afile') >> rio('anotherfile') # append the contents of 'afile' to 'anotherfile'
    #  rio('afile') >> rio('adir') # copies 'afile' to the directory 'adir'
    #  rio('adir') >> rio('anotherdir') # copy directory 'adir' recursively to 'anotherdir' 
    #  rio('adir') >> array # appendscopy directory 'adir' recursively to 'anotherdir' 
    #  rio('adir') >> ary # a Rio for each entry in the directory will be appended to ary
    def >>(destination) target >> destination; self end

    
    # Grande Append-From Operator
    # 
    # The append-from grande-operator copies a Rio from another Rio or another ruby object. This
    # behaves like Rio#< (copy-from) except unopened Rios are opened for append.
    #
    # The following summarizes how objects are copied:
    # IO::       IO#each is used to iterate through the source with each record appended to the Rio
    # Array::    Each element of the Array is appended individually to the Rio.
    # String::   The string is appended to the Rio using Rio#print
    # Rio::      The source Rio is appended using its Rio#>> (append-to) operator
    # 
    # See Rio#< (copy-from)
    def <<(source) target << source; self end

    # Grande Copy-From Operator
    # 
    # The copy-from grande-operator copies a Rio from another Rio or another ruby object. 
    # Its operation is dependent on the the file system objects referenced, the rio
    # options set, and the state of its source and destination. In the broadest of terms
    # it could be described as doing the following:
    #    source.each do |entry|
    #      destination << entry
    #    end
    # That is to say, it iterates through its argument, calling the copy-from operator
    # again for each element. While it is not implemented like this, and the above code would
    # not give the same results, This generalized description is convenient.
    # For example the code:
    #    dst < src
    #    # is like
    #    src.each { |line| dst << line }
    # for any of the following definitions of src and dst
    # * copying files
    #    src = rio('afile')
    #    dst = rio('acopy')
    # * copying parts of files
    #    src = rio('afile').lines(0..9)
    #    dst = rio('acopy')
    # * copying directories
    #    src = rio('srcdir')
    #    dst = rio('dstdir')
    # * copy directories selectively
    #    src = rio('srcdir').dirs(/^\./).files('*.tmp')
    #    dst = rio('dstdir')
    # * copying to a file from an array
    #    src = ["line0\n","line1\n"]
    #    dst = rio('afile')
    # * copying to a directory from an array
    #    array = [rio("file1"),rio("file2")]
    #    dst = rio('adir')
    # 
    # Arrays are handled differently depending on whether the rio references a file or a directory.
    # * If the destination is a file. 
    #    dest = rio('afile') 
    #    dest < array
    #    # is roughly equivelent to
    #    array.each do |el|
    #      case el
    #      when ::String then dest.print(el)
    #      when ::Rio then dest << el
    #      else dest << rio(el)
    #    end
    # * If the destination is a directory
    #    dest = rio('adir') 
    #    dest < array
    #    # is roughly equivelent to
    #    array.each do |el|
    #      case el
    #      when ::String then rio(el)
    #      when ::Rio then dest << el
    #      else dest << rio(el)
    #    end
    #
    # To improve run-time efficiency, Rio will choose from among several strategies when
    # copying. For instance when no file or directory filtering is specified, FileUtils#cp_r is
    # used to copy directories; and when no line filtering is specified, FileUtils#cp is used to copy
    # files.
    #
    #  rio('adir') < rio('anotherdir') # 'anotherdir' is copied to 'adir' using FileUtils#cp_r
    #  rio('adir') < rio('anotherdir').files('*.rb') # copy only .rb files
    #  rio('afile') < rio('anotherfile') # 'anotherfile' is copied to 'afile' using FileUtils#cp
    #  rio('afile') < ios # ios must be an IO object opened for reading
    #  rio('afile') < astring # basically the same as rio('afile').print(astring)
    #
    #  anarray = [ astring, rio('anotherfile') ] 
    #  rio('afile') < anarray # copies each element to 'afile' as if one had written
    #     ario = rio('afile')
    #     anarray.each do |el| 
    #       ario << el
    #     end
    #     ario.close
    #  rio('skeldir') < rio('adir').dirs # copy only the directory structure
    #  rio('destdir') < rio('adir').dirs.files(/^\./) # copy the directory structure and all dot files
    #  
    # See also Rio#> (copy-to), Rio#each, Rio#[]
    #
    def <(source) target < source; self end

    # Reads and returns the next record from a Rio, honoring the grande selection methods. 
    #
    # Returns nil on end of file.
    #
    # See also Rio#records, Rio#lines, Rio#each, Rio#[]
    #
    #  ario = rio('afile').lines(10..12)
    #  line10 = ario.getrec 
    #  line11 = ario.getrec 
    #  line12 = ario.getrec 
    #  a_nil  = ario.getrec 
    def getrec() target.getrec() end

  end
end
