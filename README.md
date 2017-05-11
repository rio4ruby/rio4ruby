# Rio - Ruby I/O Facilitator

**fa-cil-i-tate**:  _To make easy or easier_ 

Rio is a facade for most of the standard ruby classes that deal with
I/O; providing a simple, intuitive, succinct interface to the
functionality provided by IO, File, Dir, Pathname, FileUtils,
Tempfile, StringIO, OpenURI and others. Rio also provides an
application level interface which allows many common I/O idioms to be
expressed succinctly.

### Examples

# Iterate over the .rb files in a directory.
#  rio('adir').files('*.rb') { |entrio| ... }
#
# Return an array of the .rb files in a directory.
#  rio('adir').files['*.rb']
#


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


