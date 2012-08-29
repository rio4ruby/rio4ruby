require 'forwardable'

module RIO
  module FS
    class Handle
      def initialize(fs)
        @fs = fs
      end
      def convert_arg(arg)
        arg.to_s
      end
      def convert_args(args)
        args.map { |arg| convert_arg(arg) }
      end

      def method_missing(sym,*args,&block)
        #a = convert_args(args)
        # puts "FS::Handle:method_missing(#{sym.inspect},#{args.inspect}) #{@fs.inspect}"
        @fs.__send__(sym,*args,&block)
      end
    end
  end
end


module RIO
  module FS #:nodoc: all
    module Fwd
      module Str
        extend Forwardable
        def_delegators :@file,
        
        :fnmatch?,
        :extname,

        :basename,
        :dirname,
        :join,
        :cleanpath
      end
      module File
        extend Forwardable
        def_delegators :@file,
        :expand_path,


        :ftype,
        :symlink,

        :stat,

        :atime,
        :ctime,
        :mtime,

        :chmod,
        :chown,

        :readlink,
        :lstat,

        :truncate

      end
      module Dir
        extend Forwardable
        def_delegators :@dir,

        :rmdir,
        :mkdir,
        :chdir,
        :foreach,
        :entries,
        :glob,
        :pwd,
        :getwd
      end
      module Test
        extend Forwardable
        def_delegators :@test,
        :blockdev?,
        :chardev?,
        :directory?,
        :dir?,
        :executable?,
        :executable_real?,
        :exist?,
        :file?,
        :grpowned?,
        :owned?,
        :pipe?,
        :readable?,
        :readable_real?,
        :setgid?,
        :setuid?,
        :size,
        :size?,
        :socket?,
        :sticky?,
        :symlink?,
        :writable?,
        :writable_real?,
        :zero?
      end
      module Path
        extend Forwardable
        require 'pathname'
        def_delegators :@path,
        :root?,
        :mountpoint?,
        :realpath
      end
      module Util
        extend Forwardable
        # Directory stuff
        def_delegators :@util,
        :cp_r,
        :rmtree,
        :mkpath,
        :mv,
        :touch

        # file
        def_delegator :@file, 
        :delete 
      end
    end
  end
end
module RIO
  module FS
    class Local
      FS_ENCODING = Dir.pwd.encoding
      attr_reader :file,:dir
      def initialize(*args)
        #p "RIO::FS::Local.initialize(#{args}) pwdenc=#{}"
        @file = ::File
        @test = ::FileTest
        @dir  = ::Dir
        require 'pathname'
        @path = ::Pathname
        require 'fileutils'
        @util = ::FileUtils
      end
      def encoding
        FS_ENCODING
      end
      def root()
        require 'rio/local'
        ::RIO::Local::ROOT_DIR        
      end
      extend Forwardable
      # 'def_delegators :@test,:directory?,:file?,:exist?
      include RIO::FS::Fwd::Str
      include RIO::FS::Fwd::Test
      include RIO::FS::Fwd::Path
      include RIO::FS::Fwd::File
      include RIO::FS::Fwd::Dir
      include RIO::FS::Fwd::Util



    end


  end
end
module RIO
  module FS
    LOCAL = Handle.new(Local.new)
  end
end
