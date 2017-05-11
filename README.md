# Rio - Ruby I/O Facilitator

**fa-cil-i-tate**:  _To make easy or easier_ 

Rio is a facade for most of the standard ruby classes that deal with
I/O; providing a simple, intuitive, succinct interface to the
functionality provided by IO, File, Dir, Pathname, FileUtils,
Tempfile, StringIO, OpenURI and others. Rio also provides an
application level interface which allows many common I/O idioms to be
expressed succinctly.

### Examples

Iterate over the .rb files in a directory.
```ruby
rio('adir').files('*.rb') { |entrio| ... }
```
Return an array of the .rb files in a directory.
```ruby
rio('adir').files['*.rb']
```

Copy the .rb files in a directory.to another directory.
```ruby
rio('adir').files('*.rb') > rio('another_directory')
```

Iterate over the .rb files in a directory and its subdirectories.
```ruby
rio('adir').all.files('*.rb') { |entrio| ... }
```

Return an array of the .rb files in a directory and its subdirectories.
```ruby
rio('adir').all.files['*.rb']
```

Copy a file to a directory
```ruby
rio('adir') << rio('afile')
```

Copy a directory to another directory
```ruby
rio('adir') >> rio('another_directory')
```

Copy a web-page to a file
```ruby
rio('http://rubydoc.org/') > rio('afile')
```

Read a web-page into a string
```ruby
astring = rio('http://rubydoc.org/').read
```


Ways to get the chomped lines of a file into an array
```ruby
anarray = rio('afile').chomp[]         # subscript operator
rio('afile').chomp > anarray           # copy-to operator
anarray = rio('afile').chomp.to_a      # to_a
anarray = rio('afile').chomp.readlines # IO#readlines
```

Iterate over selected lines of a file
```ruby
 rio('adir').lines(0..3) { |aline| ... }       # a range of lines
 rio('adir').lines(/re/) { |aline| ... }       # by regular expression
 rio('adir').lines(0..3,/re/) { |aline| ... }  # or both
```
# 
Return selected lines of a file as an array
```ruby
 rio('adir').lines[0..3]       # a range of lines
 rio('adir').lines[/re/]       # by regular expression
 rio('adir').lines[0..3,/re/]  # or both
```
Iterate over selected chomped lines of a file
```ruby
 rio('adir').chomp.lines(0..3) { |aline| ... }       # a range of lines
 rio('adir').chomp.lines(/re/) { |aline| ... }       # by regular expression
```
Return selected chomped lines of a file as an array
```ruby
 rio('adir').chomp[0..3]  # a range of lines
 rio('adir').chomp[/re/]  # by regular expression
```
Copy a gzipped file un-gzipping it
```ruby
 rio('afile.gz').gzip > rio('afile')
```
Copy a plain file, gzipping it
```ruby
 rio('afile.gz').gzip < rio('afile')
```
Copy a file from a ftp server into a local file un-gzipping it
```ruby
 rio('ftp://host/afile.gz').gzip > rio('afile')
```
Return an array of .rb files excluding symlinks to .rb files
```ruby
 rio('adir').files('*.rb').skip[:symlink?]
```
Put the first 10 chomped lines of a gzipped file into an array
```ruby
 anarray =  rio('afile.gz').chomp.gzip[0...10] 
```
Copy lines 0 and 3 thru 5 of a gzipped file on an ftp server to stdout
```ruby
 rio('ftp://host/afile.gz').gzip.lines(0,3..5) > ?-
```
Return an array of files in a directory and its subdirectories, without descending into .svn directories. 
```ruby
 rio('adir').norecurse(/^\.svn$/).files[]
```
Iterate over the non-empty, non-comment chomped lines of a file
```ruby
 rio('afile').chomp.skip(:empty?,/^\s*#/) { |line| ... }
```
Copy the output of th ps command into an array, skipping the header line and the ps command entry
```ruby
 rio(?-,'ps -a').skiplines(0,/ps$/) > anarray 
```
Prompt for input and return what was typed
```ruby
 ans = rio(?-).print("Type Something: ").chomp.gets 
```
Change the extension of all .htm files in a directory and its subdirectories to .html
```ruby
 rio('adir').rename.all.files('*.htm') do |htmfile|
   htmfile.extname = '.html'
 end
```


### Installation

Add this line to your application's Gemfile:

    gem 'rio'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rio

### Usage

Rio is extensively documented at http://rio4ruby.com

* Documentation:: http://rio4ruby.com/
* Project::       https://github.com/rio4ruby/rio4ruby
* Email::         rio4ruby@rio4ruby.com


