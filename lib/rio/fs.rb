require 'rio/fwd'

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
        extend ::RIO::Fwd
        fwd_readers :@file,
                    :fnmatch?,
                    :extname,
                    :basename,
                    :dirname,
                    :join,
                    :cleanpath
      end
      module File
        extend ::RIO::Fwd
        fwd_readers :@file,
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
        extend ::RIO::Fwd
        fwd_readers :@dir,
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
        extend ::RIO::Fwd
        fwd_readers :@test,
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
        extend ::RIO::Fwd
        require 'pathname'
        fwd_readers :@path,
                    :root?,
                    :mountpoint?,
                    :realpath
      end
      module Util
        extend ::RIO::Fwd
        # Directory stuff
        fwd_readers :@util,
                    :cp_r,
                    :rmtree,
                    :mkpath,
                    :mv,
                    :touch
        
        # file
        fwd_readers :@file, 
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
