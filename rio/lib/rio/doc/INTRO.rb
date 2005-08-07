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
module Doc
=begin rdoc

= Rio - Ruby I/O Comfort Class

Rio is a convenience class wrapping much of the functionality of 
IO, File, Dir, Pathname, FileUtils,
Tempfile, StringIO, and OpenURI and uses Zlib, and CSV 
to extend that functionality using a simple consistent interface. 
Most of the instance methods of IO, File and Dir are simply forwarded to the appropriate handle
to provide identical functionality. Rio also provides a "grande" interface that 
allows many application level IO tasks to be accomplished in line or two of code.

Rio functionality can be broadly broken into three categories
* path manipulation
* file system access
* stream manipulation

Which methods are available to a given Rio, depends on the underlying object.

A Rio generally does not need to be opened or have its mode specified. 
Most of Rio's methods simply configure it. 
When an actual IO operation is specified, Rio determines how to open it based
on the object it is opening, the operation it is performing, and the options specified. 

Rio configuration methods return the Rio for easy chaining and regard the presence of a block 
as an implied +each+. 

== Using a Rio

Using a Rio can be described as having 3 steps:
* Creating a Rio (using the constructor or as the result of one of path manipulation methods)
* Configuring a Rio 
* Rio I/O

=== Creating a Rio

Rio extends Kernel with one function +rio+, its constructor. This function is overloaded to 
create any type of Rio. +rio+ looks at the class and sometimes the value of its first argument
to create an internal representation of the resource specified, additional arguments are used
as needed by the resource type. The rio constructor does not initiate any io, it does not check
for a resources existance or type. It neither knows nor cares what can be done with this Rio.
Using methods like +respond_to?+ are meaningless at best and usually misleading. 

For purposes of discussion, we divide Rios into two catagories, those that have a path
and those that don't.

==== Creating a Rio that has a path

To create a Rio that has a path the arguments to +rio+ may be:

* a string representing the entire path. The separator used for Rios is as specified in RFC1738 ('/').
   rio('adir/afile')
* a string representing a fully qualified +file+ URI as per RFC1738
   rio('file:///atopleveldir/adir/afile')
* a +URI+ object representing a +file+ or generic +URI+
   rio(URI('adir/afile'))
* the components of a path as separate arguments
   rio('adir','afile')
* the components of a path as an array
   rio(%w/adir afile/)
* another Rio
   another_rio = rio('adir/afile')
   rio(another_rio)
* any object whose +to_s+ method returns one of the above
   rio(Pathname.new('apath'))
* any combination of the above either as separate arguments or as elements of an array,
   another_rio = rio('dir1/dir2')
   auri = URI('dir4/dir5)
   rio(another_rio,'dir3',auri,'dir6/dir7')

===== Creating a Rio that refers to a web page

To create a Rio that refers to a web page the arguments to +rio+ may be:

* a string representing a fully qualified +http+ URI
   rio('http://ruby-doc.org/index.html')
* a +URI+ object representing a +http+ +URI+
   rio(URI('http://ruby-doc.org/index.html'))
* either of the above with additional path elements
   rio('http://www.ruby-doc.org/','core','classes/Object.html')
   
===== Creating a Rio that refers to a file or directory on a FTP server

To create a Rio that refers to a file on a FTP server the arguments to +rio+ may be:

* a string representing a fully qualified +ftp+ URI
   rio('ftp://user:password@ftp.example.com/afile.tar.gz')
* a +URI+ object representing a +ftp+ +URI+
   rio(URI('ftp://ftp.example.com/afile.tar.gz'))
* either of the above with additional path elements
   rio('ftp://ftp.gnu.org/pub/gnu','emacs','windows','README')
   
==== Creating Rios that do not have a path

To create a Rio without a path, the first argument to +rio+ is usually a single
character.

===== Creating a Rio that refers to a clone of your programs stdin or stdout.

<tt>rio(?-)</tt> (mnemonic: '-' is used by some Unix programs to specify stdin or stdout in place of a file)

Just as a Rio that refers to a file, does not know whether that file will be opened for reading or
writing until an io operation is specified, a <tt>stdio:</tt> Rio does not know whether it will connect
to stdin or stdout until an I/O operation is specified. 

===== Creating a Rio that refers to a clone of your programs stderr.

<tt>rio(?=)</tt> (mnemonic: '-' refers to fileno 1, so '=' refers to fileno 2)

===== Creating a Rio that refers to an arbitrary IO object.

 an_io = ::File.new('afile')
 rio(an_io)

===== Creating a Rio that refers to a file descriptor

<tt>rio(?#,fd)</tt> (mnemonic: a file descriptor is a number '#' )

 an_io = ::File.new('afile')
 rio(an_io)

===== Creating a Rio that refers to a StringIO object

<tt>rio(?")</tt> (mnemonic: '"' surrounds strings)
* create a Rio that refers to its own string
 rio(?")
* create a Rio that refers to a string of your choosing
 astring = ""
 rio(?","")

===== Creating a Rio that refers to a Tempfile object

<tt>rio(??)</tt> (mnemonic: '?' you don't know its name)
 rio(??)
 rio(??,basename='rio',tmpdir=Dir::tmpdir)

===== Creating a Rio that refers to an arbitrary TCPSocket

 rio('tcp:',hostname,port)
or
 rio('tcp://hostname:port')

===== Creating a Rio that runs an external program and connects to its stdin and stdout

<tt>rio(?-,cmd)</tt> (mnemonic: '-' is used by some Unix programs to specify stdin or stdout in place of a file)

or

<tt>rio(?`,cmd)</tt> (mnemonic: '`' (backtick) runs an external program in ruby)

This is Rio's interface to IO#popen

=== Path Manipulation

Rio's path manipulation methods are for the most part simply forwarded to the File or URI classes with
the return values converted to a Rio.

==== Creating a Rio from a Rio's component parts.

The Rio methods for creating a Rio from a Rio's component parts are 
Rio#dirname, Rio#filename, Rio#basename, and Rio#extname. 
The behavior of Rio#basename depends on the setting of the +ext+ 
configuration variable
and is different from its counterpart in the File class. The default value of the +ext+ configuration variable
is the string returned File#extname. The +ext+ configuration variable can be changed using Rio#ext and Rio#noext
and can be queried using Rio#ext?. This value is used by calls to Rio#basename.

Rio#filename returns the last component of a path, and is basically the same as +basename+ without consideration 
of an extension. So

   rio('afile.txt').basename       #=> rio('afile')
   rio('afile.txt').filename       #=> rio('afile.txt')

   ario = rio('afile.tar.gz')
   ario.basename                   #=> rio('afile.tar')
   ario.ext?                       #=> ".gz"
   ario.ext('.tar.gz').basename    #=> rio('afile')
   ario.ext?                       #=> ".tar.gz"

==== Changing a path's component parts.

Rio also provides methods for changing the component parts of its path. 
They are Rio#dirname=, Rio#filename=, Rio#basename=, and Rio#extname=. These
methods replace the part extracted as described above with their argument.

   ario = rio('dirA/dirB/afile.rb')
   ario.dirname = 'dirC'          # rio('dirC/afile.rb')
   ario.basename = 'bfile'        # rio('dirC/bfile.rb')
   ario.extname = '.txt'          # rio('dirC/bfile.txt')
   ario.filename = 'cfile.rb'     # rio('dirC/cfile.rb')

Rio also has a +rename+ mode which causes each of these to rename the actual file system
object as well as changing the Rio. This is discussed in the section on 
Renaming and Moving.
 

==== Splitting a Rio

Rio#split returns an array of Rios, one for each path element. (Note that this behavior differs
from File#split.)

   rio('a/b/c').split   #=> [rio('a'),rio('b'),rio('c')]

The array returned is extended with a +to_rio+ method, which will put the parts back together again.

   ary = rio('a/b/c').split   #=> [rio('a'),rio('b'),rio('c')]
   ary.to_rio           #=> rio('a/b/c')

==== Creating a Rio by specifying the individual parts of its path

The first way to create a Rio by specifying its parts is to use the Rio constructor Rio#rio. Since 
a Rio is among the arguments the constructor will take, the constructor can be used.
   ario = rio('adir')
   rio(ario,'b')    #=> rio('adir/b')

Rio#join and Rio#/ do the same thing, but the operator version <tt>/</tt> can take only one argument.

   a = rio('a')
   b = rio('b')
   c = a.join(b)    #=> rio('a/b')
   c = a/b          #=> rio('a/b')

The arguments to +join+ and <tt>/</tt> do not need to be Rios, of course
   ario = rio('adir')
   ario/'afile.rb'           #=> rio('ario/afile.rb')
   ario.join('b','c','d')    #=> rio('ario/b/c/d')
   ario/'b'/'c'/'d'          #=> rio('ario/b/c/d')
   ario /= 'e'               #=> rio('ario/b/c/d/e')

==== Manipulating a Rio path by treating it as a string.

The Rio methods which treat a Rio as a string are Rio#sub, Rio#gsub and Rio#+.
These methods create a new Rio using the string created by forwarding the method 
to the String returned by Rio#to_s.

   ario = rio('dirA/dirB/afile') + '-1.1.1'   # rio('dirA/dirB/afile-1.1.1')
   brio = ario.sub(/^dirA/, 'dirC')           # rio('dirC/dirB/afile-1.1.1')                         
                            

==== Creating a Rio based on its relationship to another

Rio#abs creates a new rio whose path is the absolute path of a Rio.
If provided with an argument, it uses that as the base path, otherwise
it uses an internal base path (usually the current working directory when
it was created).

   rio('/tmp').chdir do
     rio('a').abs            #=> rio('/tmp/a')
     rio('a').abs('/usr')    #=> rio('/usr/a')
   end

Rio#rel creates a new rio with a path relative to a Rio.

   rio('/tmp').chdir do
     rio('/tmp/a').rel       #=> rio('a')
   end
   rio('/tmp/b').rel('/tmp') #=> rio('b')

Rio#route_to and Rio#route_from creates a new rio with a path representing
the route to get to/from a Rio. They are based on the methods of the
same names in the URI class

=== Configuring a Rio

The second step in using a rio is configuring it. Note that many times no configuration is necessary 
and that this is not a comprehensive list of all of Rio's configuration methods.

Rio's configuration mehods fall into three categories.

[IO manipulators]
  An IO manipulator alters the behavior of a Rio's underlying IO object. These affect the behaviour
  of I/O methods which are forwarded directly to the underlying object as well as the grande I/O methods.

[Grande configuration methods]
  The grande configuration methods affect the behaviour of Rio's grande I/O methods

[Grande selection methods]
  The grande selection methods select what data is returned by Rio's grande I/O methods

All of Rio's configuration and selection methods can be passed a block, which will cause the Rio to behave as if
+each+ had been called with the block after the method.

==== IO manipulators

* +gzip+ a file on output, and ungzip it on input
   rio('afile.gz').gzip
  This causes the rio to read through a Zlib::GzipReader and to write Zlib::GzipWriter.

* +chomp+ lines as they are read
   rio('afile').chomp
  This causes a Rio to call String#chomp on the the String returned by all line oriented read operations.

==== Grande configuration methods

* +all+, +recurse+, +norecurse+
   rio('adir').all
   rio('adir').norecurse('CVS')
  These methods instruct the Rio to also include entries in subdirectories when iterating through directories
  and control which subdirectories are included or excluded.

* +bytes+
   rio('afile').bytes(1024)
  This causes a Rio to read the specified number of bytes at a time as a file is iterated through.

==== Grande selection methods

* +lines+, +nolines+
   rio('afile').lines(0..9)
   rio('afile').nolines(/^\s*#/)
  Strictly speaking these are both configuration and selection methods. They configure the Rio to 
  iterate through an input stream as lines. The arguments select which lines are actually returned.
  Lines are included (+lines+) or excluded (+nolines+) if they match *any* of the arguments as follows.

  If the argument is a:
  +RegExp+::  the line is matched against it
  +Range+::   the lineno is matched against it
  +Integer+:: the lineno is matched against it as if it were a one element range
  +Symbol+::  the symbol is +sent+ to the string; the line is included unless it returns false
  +Proc+::    the proc is called with the line as an argument; the line is included unless it returns false

* +entries+, +files+, +dirs+, +noentries+, +nofiles+, +nodirs+

   rio('adir').files('*.txt')
   rio('adir').nofiles(/^\./)

  These methods select which entries will be returned when iterating throug directories.
  Entries are included (+entries+,+files+,+dirs+) or excluded(+noentries+,+nofiles+,+nodirs+) if they 
  match *any* of the arguments as follows.

  If the argument is a:
  +String+:: the arg is treated as a glob; the filname is matched against it
  +RegExp+:: the filname is matched against it
  +Symbol+:: the symbol is +sent+ to the entry (a Rio); the entry is included unless it returns false
  +Proc+:: the proc is called with the entry (a Rio) as an argument; the entry is included unless it returns false

* +records+, +rows+, +norecords+, +norows+
   rio('afile').bytes(1024).records(0...10)
  These select items from an input stream just as +lines+, but without specifying lines as the input
  record type. They can be used to select different record types in extension modules. The only
  such module at this writing is the CSV extension. In that case +records+ causes each line of
  a CSV file to be parsed into an array while +lines+ causes each line of the file to be returned normally.

=== Rio I/O

As stated above the the three steps to using a Rio are:
* Creating a Rio
* Configuring a Rio
* Doing I/O

This section describes that final step.

After creating and configuring a Rio, the file-system has not been accessed, no socket has been opened, 
not so much as a test for a files existance has been done. When an I/O method is called on a Rio, the 
sequence of events required to complete that operation on the underlying object takes place. Rio takes
care of creating the apropriate object (eg IO,Dir), opening the object with the apropriate mode, 
performing the operation, closing the object if required, and returning the results of the operation. 

Rio's I/O operations can be divide into two catagories:
* Proxy operations
* Grande operations

==== Proxy operations
  
These are calls which are forwarded to the underlying object (eg IO,Dir,Net::FTP), after apropriately
creating and configuring that object. The result produced by the method is returned, and 
the object is closed.

In some cases the result is modified before being returned, as when a Rio is configured with +chomp+.

In all cases, if the result returned by the underlying object, could itself be used for further I/O
operations it is returned as a Rio. For example: where File#dirname returns a string, Rio#dirname
returns a Rio; where Dir#read returns a string representing a directory entry, Rio#read
returns a Rio.

With some noteable exceptions, most of the operations available if one were using the underlying 
Ruby I/O class are available to the Rio and will behave identically. 

For things that exist on a file system:
* All the methods in FileTest are available as Rio instance methods. For example
   FileTest.file?('afile')
  becomes
   rio('afile').file?
* All the instance methods of +File+ except +path+ are available to a rio without change
* Most of the class methods of +File+ are available. 
  * For those that take a filename as their only argument the calls are mapped to 
    Rio instance methods as described above for FileTest.
  * +dirname+, and +readlink+ return Rios instead of strings
  * Rio has its own Rio#basename, Rio#join and Rio#symlink, which provide similar functionality.
  * The class methods which take multiple filenames (+chmod+,+chown+,+lchmod+,+lchown+) are available
    as Rio instance methods. For example
     File.chmod(0666,'afile')
    becomes
     rio('afile').chmod(06660)

For I/O Streams

Most of the instance methods of IO are available, and most do the same thing, with some interface changes.
<b>The big exception to this is the '<<' operator.</b> This is one of Rio's grande operators. While the symantics
one would use to write to an IO object would actually accomplish the same thing with a Rio, It is a
very different operator. Read the section on grande operators. The other differences between IO
instance methods and the Rio equivelence can be summarized as follows.
* The simple instance methods (eg +fcntl+, <tt>eof?</tt>, <tt>tty?</tt> etc.)
  are forwarded and the result returned as is
* Anywhere IO returns an IO, Rio returns a Rio
* +close+ and its cousins return the Rio. 
* +each_byte+ and +each_line+ are forwarded as is.
* All methods which read (read*,get*,each*) will cause the file to closed when the end of file is reached.
  This behavior is configurable, but the default is to close on eof
* The methods which write (put*,print*) are forwarded as is; put* and print* return the Rio; write returns
  the value returned by IO#write; as mentioned above '<<' is a grande operator in Rio.

For directories:

* all the instance methods of Dir are available except +each+ which is a grande method. 
* the class methods +mkdir+, +delete+, +rmdir+ are provided as instance methods.
* +chdir+ is provided as an instance method. Rio#chdir returns a Rio and passes a Rio to a block if one is provided.
* +glob+ is provided as an instance method, but returns an array of Rios
* +foreach+ is not supported
* +each+ and <tt>[]</tt> have similar functionality provided by Rio


For other Rios, instance methods are generally forwarded where appropriate. For example

* Rios that refer to StringIO objects forward 'string' and 'string='
* Rios that refer to http URIs support all the Meta methods provided by open-uri

  
==== Grande operators

The primary grande operator is Rio#each. +each+ is used to iterate through Rios. When applied
to a file it iterates through records in the file. When applied to a directory it iterates through
the entries in the directory. Its behavior is modified by configuring the Rio prior to calling it using
the configuration methods discussed above. Since iterating through things is ubiquitous in ruby, it is implied 
by the presence of a block after any of the grande configuration methods and many times does not need to be
call explicitly. For example:

 rio('afile.rb').chomp.lines(/^\s*#/) { |line| ... } # iterate through chomped ruby comment lines
 rio('adir').all.files('*.rb') { |f| ... } # iterate through all .rb files in 'adir' and its subdirectories

Because a Rio is an Enumerable, it supports +to_a+, which is the basis for the grande subscript operator.
Rio#[] with no arguments simply calls to_a. With arguments it behaves as if those arguments had been
passed to the most recently called of the grande selection methods listed above, and then calls to_a. For example
to get the first ten lines of a file into an array with lines chomped
 rio('afile').chomp.lines(0...10).to_a
can be written as
 rio('afile.gz').chomp.lines[0...10]
or, to create an array of all the .c files in a directory, one could write
 rio('adir').files['*.c']

The other grande operators are its copy operators. They are:
* <tt><</tt> (copy-from)
* <tt><<</tt> (append-from)
* <tt>></tt> (copy-to)
* <tt>>></tt> (append-to)
The only difference between the 'copy' and 'append' versions is how they deal with an unopened resource. 
In the former the open it with mode 'w' and in the latter, mode 'a'.
Beyond that, their behavior can be summarized as:
   source.each do |entry|
     destination << entry
   end
Since they are based on the +each+ operator, all of the selection and configuration options are available.
And the right-hand-side argument of the operators are not restricted to Rios -- Strings and Arrays are also supported.

For example:
 rio('afile') > astring # copy a file into a string

 rio('afile').chomp > anarray # copy the chomped lines of afile into an array

 rio('afile.gz').gzip.lines(0...100) > rio('bfile') # copy 100 lines from a gzipped file into another file

 rio(?-) < rio('http://rubydoc.org/') # copy a web page to stdout

 rio('bdir') < rio('adir') # copy an entire directory structure

 rio('adir').dirs.files('README') > rio('bdir') # same thing, but only README files

 rio(?-,'ps -a').nolines(0,/ps$/) > anarray # copy the output of th ps command into an array, skippying
                                            # the header line and the ps command entry

=== Renaming and Moving

Rio provides two methods for directly renaming objects on the filesystem:
Rio#rename and Rio#rename!. Both of these use File#rename. The difference
between them is the returned Rio. Rio#rename leaves the path of the Rio unchanged,
while Rio#rename! changes the path of the Rio to refer to the renamed path.
   ario = rio('a')
   ario.rename('b')  # file 'a' has been renamed to 'b' but 'ario' => rio('a')
   ario.rename!('b')  # file 'a' has been renamed to 'b' and 'ario' => rio('b')

Rio also has a +rename+ mode, which causes the path manipulation methods Rio#dirname=,
Rio#filename=, Rio#basename= and Rio#extname= to rename an object on the filesystem
when they are used to change a Rio's path. A Rio is put in +rename+ mode by
calling Rio#rename with no arguments.

   rio('adir/afile.txt').rename.filename = 'bfile.rb' # adir/afile.txt => adir/bfile.rb
   rio('adir/afile.txt').rename.basename = 'bfile'    # adir/afile.txt => adir/bfile.txt
   rio('adir/afile.txt').rename.extname  = '.rb'      # adir/afile.txt => adir/afile.rb
   rio('adir/afile.txt').rename.dirname =  'b/c'      # adir/afile.txt => b/c/afile.txt

When +rename+ mode is set for a directory Rio, it is automatically set in the Rios created
when iterating through that directory.

   rio('adir').rename.files('*.htm') do |frio|
      frio.extname = '.html'  #=> changes the rio and renames the file
   end

=== Deleting 

The Rio methods for deleting filesystem objects are Rio#rm, Rio#rmdir, Rio#rmtree, Rio#delete,
and Rio#delete!. +rm+, +rmdir+ and +rmtree+ are passed the like named methods in the FileUtils
module. Rio#delete calls +rmdir+ for directories and +rm+ for anything else, while Rio#delete! 
calls Rio#rmtree for directories.

* To delete something only if it is not a directory use Rio#rm
* To delete an empty directory use Rio#rmdir
* To delete an entire directory tree use Rio#rmtree
* To delete anything except a populated directory use Rio#delete
* To delete anything use Rio#delete!

It is not an error to call any of the deleting methods on something that does not exist. Rio provides
Rio#exist? and Rio#symlink? to check if something exists (<tt>exist?</tt> returns false for 
symlinks to non-existant object even though the symlink itself exists). 
The deleting methods' purpose is to make things not exist, so
calling one of them on something that already does not exist is considered a success.

To create a clean copy of a directory whether or not anything with that name exists one might do this
 rio('adir').delete!.mkpath.chdir do
   # do something in adir
 end

=== Using Symbolic Links

To create a symbolic link (symlink) to the file-system entry refered to by a Rio, use Rio#symlink. 
Rio#symlink differs from File#symlink in that it calculates the path from the symlink location to 
the Rio's position. So:

 File#symlink('adir/afile','adir/alink')

creates a symlink in the directory 'adir' named 'alink' which references 'adir/afile'. From the 
perspective of 'alink', 'adir/afile' does not exist. While:

 rio('adir/afile').symlink('adir/alink')

creates a symlink in the directory 'adir' named 'alink' which references 'afile'. This is the route
to 'adir/afile' from the perspective of 'adir/alink'. 

Note that the return value from +symlink+ is the calling Rio and not a Rio refering to the symlink.
This is done for consistency with the rest of Rio.

Rio#symlink? can be used to test if a file-system object is a symlink. A Rio is extended with
Rio#readlink, and Rio#lstat only if Rio#symlink? returns true. So for non-symlinks, these
will raise a NoMethodError. These are both passed to their counterparts in File. Rio#readlink
returns a Rio refering to the result of File#readlink.

=== Using A Rio as an IO (or File or Dir)

Rio supports so much of IO's interface that one might be tempted to pass it to a method that 
expects an IO. While Rio is not and is not intended to be a stand in for IO, this can work. 
It requires knowledge of every IO method that will be called, under any circumstances. 

Even in cases where Rio supports the IO interface, A Rio feature that seems to 
cause the most incompatibility, is its automatic closing of files. To turn off all of Rio's
automatic closing use Rio#noclose.

For example:
 require 'yaml'
 yrio = rio('ran.yaml').delete!.noclose
 rtn2 = YAML.dump( ['badger', 'elephant', 'tiger'], yrio )
 obj = YAML::load( yrio )

---


See also:
* RIO::Doc::SYNOPSIS
* RIO::Doc::HOWTO
* RIO::Rio

=end
module INTRO
end
end
end
