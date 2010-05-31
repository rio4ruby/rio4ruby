# -*- mode: ruby; ruby-indent-level: 2; tab-width: 2 -*-
# vim: noet ts=2 sts=8 sw=2

require 'pathname'
require 'fileutils'
require 'erb'
#p 'RIO RIO RIO RIO RIO RIO'
#require 'rdoc/generator/markup'

module Alt
end


class Alt::ToHtmlCrossref < RDoc::Markup::ToHtml

  ##
  # Regular expression to match class references
  #
  # 1) There can be a '\' in front of text to suppress any cross-references
  # 2) There can be a '::' in front of class names to reference from the
  #    top-level namespace.
  # 3) The method can be followed by parenthesis

  CLASS_REGEXP_STR = '\\\\?((?:\:{2})?[A-Z]\w*(?:\:\:\w+)*)'

  ##
  # Regular expression to match method references.
  #
  # See CLASS_REGEXP_STR
  METHOD_NAME_REGEXP_STR = '[a-z]\w*[!?=]?|<{1,2}|>{1,2}|\[\]|\||\/|[-+]@?|={2,3}|=~'
  #METHOD_NAME_REGEXP_STR = '[a-z]\w*[!?=]?'
  METHOD_REGEXP_STR = "(#{METHOD_NAME_REGEXP_STR})(?:\([\w.+*/=<>-]*\))?"

  ##
  # Regular expressions matching text that should potentially have
  # cross-reference links generated are passed to add_special.  Note that
  # these expressions are meant to pick up text for which cross-references
  # have been suppressed, since the suppression characters are removed by the
  # code that is triggered.

  CROSSREF_REGEXP = /(
                      # A::B::C.meth
                      #{CLASS_REGEXP_STR}(?:[.#]|::)#{METHOD_REGEXP_STR}

                      # Stand-alone method (proceeded by a #)
                      | \\?\##{METHOD_REGEXP_STR}

                      # Stand-alone method (proceeded by ::)
                      | ::#{METHOD_REGEXP_STR}

                      # A::B::C
                      # The stuff after CLASS_REGEXP_STR is a
                      # nasty hack.  CLASS_REGEXP_STR unfortunately matches
                      # words like dog and cat (these are legal "class"
                      # names in Fortran 95).  When a word is flagged as a
                      # potential cross-reference, limitations in the markup
                      # engine suppress other processing, such as typesetting.
                      # This is particularly noticeable for contractions.
                      # In order that words like "can't" not
                      # be flagged as potential cross-references, only
                      # flag potential class cross-references if the character
                      # after the cross-referece is a space or sentence
                      # punctuation.
                      | #{CLASS_REGEXP_STR}(?=[\s\)\.\?\!\,\;]|\z)

                      # Things that look like filenames
                      # The key thing is that there must be at least
                      # one special character (period, slash, or
                      # underscore).
                      | (?:\.\.\/)*[-\/\w]+[_\/\.][-\w\/\.]+

                      # Things that have markup suppressed
                      | \\[^\s]
                      )/x

  ##
  # RDoc::CodeObject for generating references

  attr_accessor :context

  ##
  # Creates a new crossref resolver that generates links relative to +context+
  # which lives at +from_path+ in the generated files.  '#' characters on
  # references are removed unless +show_hash+ is true.

  def initialize(from_path, context, show_hash)
    raise ArgumentError, 'from_path cannot be nil' if from_path.nil?
    super()

    @markup.add_special(CROSSREF_REGEXP, :CROSSREF)

    @from_path = from_path
    @context = context
    @show_hash = show_hash

    @seen = {}
  end

  ##
  # We're invoked when any text matches the CROSSREF pattern.  If we find the
  # corresponding reference, generate a hyperlink.  If the name we're looking
  # for contains no punctuation, we look for it up the module/class chain.
  # For example, HyperlinkHtml is found, even without the Generator:: prefix,
  # because we look for it in module Generator first.

  def handle_special_CROSSREF(special)
    #p "handle_special_CROSSREF special=#{special.text}" if special.text =~ /^RIO/
    name = special.text

    # This ensures that words entirely consisting of lowercase letters will
    # not have cross-references generated (to suppress lots of erroneous
    # cross-references to "new" in text, for instance)
    return name if name =~ /\A[a-z]*\z/

    return @seen[name] if @seen.include? name

    lookup = name

    name = name[0, 1] unless @show_hash if name[0, 1] == '#'

    # Find class, module, or method in class or module.
    #
    # Do not, however, use an if/elsif/else chain to do so.  Instead, test
    # each possible pattern until one matches.  The reason for this is that a
    # string like "YAML.txt" could be the txt() class method of class YAML (in
    # which case it would match the first pattern, which splits the string
    # into container and method components and looks up both) or a filename
    # (in which case it would match the last pattern, which just checks
    # whether the string as a whole is a known symbol).

    if /#{CLASS_REGEXP_STR}([.#]|::)#{METHOD_REGEXP_STR}/ =~ lookup then
      container = $1
      type = $2
      type = '#' if type == '.'
      method = "#{type}#{$3}"
      ref = @context.find_symbol container, method
    end

    ref = @context.find_symbol lookup unless ref

    out = if lookup == '\\' then
            lookup
          elsif lookup =~ /^\\/ then
            $'
          elsif ref and ref.document_self then
            #p "handle_special_CROSSREF name=#{name}"
            shname = name.sub(/^IF::.+\#/,'#').
              sub(/^RIO::IF::.+\#/,'').
              sub(/^RIO::Rio\#/,'')

            "<a href=\"#{ref.as_href @from_path}\">#{shname}</a>"
          else
            name
          end

    @seen[name] = out

    out
  end

end


$RIOFISH_DRYRUN = false # TODO make me non-global
module RDoc::Generator::Markup
  ##
  # Creates an RDoc::Markup::ToHtmlCrossref formatter

  def formatter
    return @formatter if defined? @formatter
    show_hash = RDoc::RDoc.current.options.show_hash
    this = RDoc::Context === self ? self : @parent
    #@formatter = RDoc::Markup::ToHtmlCrossref.new this.path, this, show_hash
    @formatter = Alt::ToHtmlCrossref.new this.path, this, show_hash
  end


end

class RDoc::Generator::Riofish

	RDoc::RDoc.add_generator( self )

	include ERB::Util

	# Subversion rev
	SVNRev = %$Rev: 52 $

	# Subversion ID
	SVNId = %$Id: riofish.rb 52 2009-01-07 02:08:11Z deveiant $

	# Path to this file's parent directory. Used to find templates and other
	# resources.
	GENERATOR_DIR = File.join 'resources', 'generator'

	# Release Version
	VERSION = '1.1.6'

	# Directory where generated classes live relative to the root
	CLASS_DIR = nil

	# Directory where generated files live relative to the root
	FILE_DIR = nil


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Standard generator factory method
	def self::for( options )
		new( options )
	end


	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################


	### Initialize a few instance variables before we start
	def initialize( options )
		@options = options

		template = @options.template || 'riofish'

		template_dir = $LOAD_PATH.map do |path|
			File.join File.expand_path(path), GENERATOR_DIR, 'template', template
		end.find do |dir|
			File.directory? dir
		end

		raise RDoc::Error, "could not find template #{template.inspect}" unless
			template_dir

		@template_dir = Pathname.new File.expand_path(template_dir)

		@files      = nil
		@classes    = nil

		@basedir = Pathname.pwd.expand_path
	end

	######
	public
	######

	# The output directory
	attr_reader :outputdir


	### Output progress information if debugging is enabled
	def debug_msg( *msg )
		return unless $DEBUG_RDOC
		$stderr.puts( *msg )
	end

	def class_dir
		CLASS_DIR
	end

	def file_dir
		FILE_DIR
	end

	### Create the directories the generated docs will live in if
	### they don't already exist.
	def gen_sub_directories
		@outputdir.mkpath
	end

	### Copy over the stylesheet into the appropriate place in the output
	### directory.
	def write_style_sheet
		debug_msg "Copying static files"
		options = { :verbose => $DEBUG_RDOC, :noop => $RIOFISH_DRYRUN }

		FileUtils.cp @template_dir + 'rdoc.css', '.', options

		Dir[(@template_dir + "{js,images}/**/*").to_s].each do |path|
			next if File.directory? path
			next if path =~ /#{File::SEPARATOR}\./

			dst = Pathname.new(path).relative_path_from @template_dir

			# I suck at glob
			dst_dir = dst.dirname
			FileUtils.mkdir_p dst_dir, options unless File.exist? dst_dir

			FileUtils.cp @template_dir + path, dst, options
		end
	end

	### Build the initial indices and output objects
	### based on an array of TopLevel objects containing
	### the extracted information.
	def generate( top_levels )
		@outputdir = Pathname.new( @options.op_dir ).expand_path( @basedir )

		@files = top_levels.sort
		@classes = RDoc::TopLevel.all_classes_and_modules.sort
		@methods = @classes.map { |m| m.method_list }.flatten.sort
		@modsort = get_sorted_module_list( @classes )

		# Now actually write the output
		write_style_sheet
		generate_index
		generate_class_files
		#generate_class_metamenu_files
		generate_file_files

	rescue StandardError => err
		debug_msg "%s: %s\n  %s" % [ err.class.name, err.message, err.backtrace.join("\n  ") ]
		raise
	end

	#########
	protected
	#########

	### Return a list of the documented modules sorted by salience first, then
	### by name.
	def get_sorted_module_list( classes )
		nscounts = classes.inject({}) do |counthash, klass|
			top_level = klass.full_name.gsub( /::.*/, '' )
			counthash[top_level] ||= 0
			counthash[top_level] += 1

			counthash
		end

		# Sort based on how often the top level namespace occurs, and then on the
		# name of the module -- this works for projects that put their stuff into
		# a namespace, of course, but doesn't hurt if they don't.
		classes.sort_by do |klass|
			top_level = klass.full_name.gsub( /::.*/, '' )
			[
				nscounts[ top_level ] * -1,
				klass.full_name
			]
		end.select do |klass|
			klass.document_self
		end
	end

	### Generate an index page which lists all the classes which
	### are documented.
	def generate_index
		template_file = @template_dir + 'index.rhtml'
		return unless template_file.exist?

		debug_msg "Rendering the index page..."

		template_src = template_file.read
		template = ERB.new( template_src, nil, '<>' )
		template.filename = template_file.to_s
		context = binding()

		output = nil

		begin
			output = template.result( context )
		rescue NoMethodError => err
			raise RDoc::Error, "Error while evaluating %s: %s (at %p)" % [
				template_file,
				err.message,
				eval( "_erbout[-50,50]", context )
			], err.backtrace
		end

		outfile = @basedir + @options.op_dir + 'index.html'
		unless $RIOFISH_DRYRUN
			debug_msg "Outputting to %s" % [outfile.expand_path]
			outfile.open( 'w', 0644 ) do |fh|
				fh.print( output )
			end
		else
			debug_msg "Would have output to %s" % [outfile.expand_path]
		end
	end

	### Generate a documentation file for each class
	def generate_class_files
		template_file = @template_dir + 'classpage.rhtml'
		return unless template_file.exist?
		debug_msg "Generating class documentation in #@outputdir"

		@classes.each do |klass|
			debug_msg "  working on %s (%s)" % [ klass.full_name, klass.path ]
			#p "  working on %s (%s)" % [ klass.full_name, klass.path ]
			outfile    = @outputdir + klass.path
			rel_prefix = @outputdir.relative_path_from( outfile.dirname )
			svninfo    = self.get_svninfo( klass )

			debug_msg "  rendering #{outfile}"
			self.render_template( template_file, binding(), outfile )
		end
	end

	### Generate a documentation file for each class
	def generate_class_metamenu_files
		template_file = @template_dir + 'classpage-metamenu.rhtml'
		return unless template_file.exist?
		debug_msg "Generating class documentation in #@outputdir"

		@classes.each do |klass|
			debug_msg "  working on %s (%s)" % [ klass.full_name, klass.path ]
			#p "  working on %s (%s)" % [ klass.full_name, klass.path ]
      kp = File.basename(klass.path,File.extname(klass.path)) + '-metamenu' + File.extname(klass.path)
      dn = File.dirname(klass.path)
      dn = dn == "." ? "" : dn + "/"
      #p "dn=#{dn}"
			outfile    = @outputdir + dn + kp
      rel_prefix = @outputdir.relative_path_from( outfile.dirname )
			svninfo    = self.get_svninfo( klass )

			debug_msg "  rendering #{outfile}"
			self.render_template( template_file, binding(), outfile )
		end
	end

	### Generate a documentation file for each file
	def generate_file_files
		template_file = @template_dir + 'filepage.rhtml'
		return unless template_file.exist?
		debug_msg "Generating file documentation in #@outputdir"

		@files.each do |file|
			outfile     = @outputdir + file.path
			debug_msg "  working on %s (%s)" % [ file.full_name, outfile ]
			rel_prefix  = @outputdir.relative_path_from( outfile.dirname )
			context     = binding()

			debug_msg "  rendering #{outfile}"
			self.render_template( template_file, binding(), outfile )
		end
	end


	### Return a string describing the amount of time in the given number of
	### seconds in terms a human can understand easily.
	def time_delta_string( seconds )
		return 'less than a minute' if seconds < 1.minute
		return (seconds / 1.minute).to_s + ' minute' + (seconds/60 == 1 ? '' : 's') if seconds < 50.minutes
		return 'about one hour' if seconds < 90.minutes
		return (seconds / 1.hour).to_s + ' hours' if seconds < 18.hours
		return 'one day' if seconds < 1.day
		return 'about one day' if seconds < 2.days
		return (seconds / 1.day).to_s + ' days' if seconds < 1.week
		return 'about one week' if seconds < 2.week
		return (seconds / 1.week).to_s + ' weeks' if seconds < 3.months
		return (seconds / 1.month).to_s + ' months' if seconds < 1.year
		return (seconds / 1.year).to_s + ' years'
	end


	# %q$Id: riofish.rb 52 2009-01-07 02:08:11Z deveiant $"
	SVNID_PATTERN = /
		\$Id:\s
			(\S+)\s					# filename
			(\d+)\s					# rev
			(\d{4}-\d{2}-\d{2})\s	# Date (YYYY-MM-DD)
			(\d{2}:\d{2}:\d{2}Z)\s	# Time (HH:MM:SSZ)
			(\w+)\s				 	# committer
		\$$
	/x

	### Try to extract Subversion information out of the first constant whose value looks like
	### a subversion Id tag. If no matching constant is found, and empty hash is returned.
	def get_svninfo( klass )
		constants = klass.constants or return {}

		constants.find {|c| c.value =~ SVNID_PATTERN } or return {}

		filename, rev, date, time, committer = $~.captures
		commitdate = Time.parse( date + ' ' + time )

		return {
			:filename    => filename,
			:rev         => Integer( rev ),
			:commitdate  => commitdate,
			:commitdelta => time_delta_string( Time.now.to_i - commitdate.to_i ),
			:committer   => committer,
		}
	end


	### Load and render the erb template in the given +template_file+ within the
	### specified +context+ (a Binding object) and write it out to +outfile+.
	### Both +template_file+ and +outfile+ should be Pathname-like objects.

	def render_template( template_file, context, outfile )
		template_src = template_file.read
		template = ERB.new( template_src, nil, '<>' )
		template.filename = template_file.to_s

		output = begin
							 template.result( context )
						 rescue NoMethodError => err
							 raise RDoc::Error, "Error while evaluating %s: %s (at %p)" % [
								 template_file.to_s,
								 err.message,
								 eval( "_erbout[-50,50]", context )
							 ], err.backtrace
						 end

		unless $RIOFISH_DRYRUN
			outfile.dirname.mkpath
			outfile.open( 'w', 0644 ) do |ofh|
				ofh.print( output )
			end
		else
			debug_msg "  would have written %d bytes to %s" %
			[ output.length, outfile ]
		end
	end

end # Roc::Generator::Riofish

# :stopdoc:

### Time constants
module TimeConstantMethods # :nodoc:

	### Number of seconds (returns receiver unmodified)
	def seconds
		return self
	end
	alias_method :second, :seconds

	### Returns number of seconds in <receiver> minutes
	def minutes
		return self * 60
	end
	alias_method :minute, :minutes

	### Returns the number of seconds in <receiver> hours
	def hours
		return self * 60.minutes
	end
	alias_method :hour, :hours

	### Returns the number of seconds in <receiver> days
	def days
		return self * 24.hours
	end
	alias_method :day, :days

	### Return the number of seconds in <receiver> weeks
	def weeks
		return self * 7.days
	end
	alias_method :week, :weeks

	### Returns the number of seconds in <receiver> fortnights
	def fortnights
		return self * 2.weeks
	end
	alias_method :fortnight, :fortnights

	### Returns the number of seconds in <receiver> months (approximate)
	def months
		return self * 30.days
	end
	alias_method :month, :months

	### Returns the number of seconds in <receiver> years (approximate)
	def years
		return (self * 365.25.days).to_i
	end
	alias_method :year, :years


	### Returns the Time <receiver> number of seconds before the
	### specified +time+. E.g., 2.hours.before( header.expiration )
	def before( time )
		return time - self
	end


	### Returns the Time <receiver> number of seconds ago. (e.g.,
	### expiration > 2.hours.ago )
	def ago
		return self.before( ::Time.now )
	end


	### Returns the Time <receiver> number of seconds after the given +time+.
	### E.g., 10.minutes.after( header.expiration )
	def after( time )
		return time + self
	end

	# Reads best without arguments:  10.minutes.from_now
	def from_now
		return self.after( ::Time.now )
	end
end # module TimeConstantMethods


# Extend Numeric with time constants
class Numeric # :nodoc:
	include TimeConstantMethods
end

