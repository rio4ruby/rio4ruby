require 'fiber'

module RIO
  class IOPair
    attr_accessor :in,:out
    def initialize(out=nil,inp=nil)
      @in,@out = inp,out
    end
    alias :rd :out
    alias :wr :in
  end
  class IOPipe < IOPair
    def initialize
      rd,wr = IO.pipe
      super(rd,wr)
    end
  end
end

module RIO
  module Cmd

    class NamedFiber < Fiber
      attr :name
      def initialize(name="unnamed")
        @name = name
        super()
      end
    end

    class FibPipe
      @@depth = 0
      attr :fib,:data
      attr_accessor :source
      def initialize(fib)
        @fib = fib
        @data = IOPair.new
        @source = nil
      end
      def resume(*args) 
        fib.resume(*args)
      end
      def source_resume(*args)
        @@depth += 1
        source.resume(*args)
      end
      def fiber_yield(*args)
        @@depth -= 1
        Fiber.yield(*args)
      end
      def dest_wait_for_reader
        while ans = fiber_yield(nil)
          p "   #{self.class}: Waiting #{ans.inspect}"
          sleep 1
          #break
        end
      end
      def dest_report_new_data
        fiber_yield true
      end
      def dest_report_data_done
        fiber_yield nil
      end
      def _fiber_init(trail)
        self.source = trail.shift
      end
    end

  end
end

module RIO
  module Cmd

    class To < FibPipe
      BUF_LEN = 128
      def initialize(io)
        super(_create_input_fiber)
        data.out = io
      end
      def _fiber_init(trail)
        super
        data.in = source.pipe.out
        source_resume trail
      end
    end

  end
end


module RIO
  module Cmd

    class ToOutput < To
      def initialize(out,is_dest=true,is_duplex=nil)
        super(out)
        @is_dest = is_dest
        @is_duplex = is_duplex ? is_duplex : !@is_dest
      end
      def dest?() @is_dest end
      def duplex?() @is_duplex end
      def put(rec)
        data.out.write(rec)
      end
      def process_loop
        loop do 
          begin
            rec = data.in.read_nonblock(BUF_LEN)
            put(rec)
            dest_report_new_data unless dest?
          rescue Errno::EWOULDBLOCK
            source_resume true
          rescue Errno::EINTR
            break
          rescue EOFError
            data.in.close_read
            if duplex?
              data.out.close_write
            else
              data.out.close
            end
            dest_report_data_done unless dest?
            break
          end
        end
      end
      def _create_input_fiber
        fibname = /[^:]+$/.match(self.class.to_s)[0]
        NamedFiber.new(fibname) do |trail|
          _fiber_init(trail)
          process_loop
          dest_wait_for_reader unless dest?
        end
      end
    end

  end
end

module RIO
  module Cmd

    class ToStdout < ToOutput
      def initialize
        super($stdout)
      end
    end

    class ToProc < ToOutput
      def initialize(ioproc)
        super(ioproc,false)
      end
      def put(rec)
        data.out.write(rec)
        data.out.flush
      end
    end

  end
end


module RIO
  module Cmd

    class From < FibPipe
      attr :pipe
      def initialize(io)
        super(_create_output_fiber)
        @pipe = IOPipe.new
        data.in = io
        data.out = @pipe.wr
      end
      def _fiber_init(trail)
        super
        source_resume(trail) if source
      end
      def _create_output_fiber
        fibname = /[^:]+$/.match(self.class.to_s)[0]
        NamedFiber.new(fibname) do |trail|
          _fiber_init(trail)
          process_loop
          dest_wait_for_reader
        end
      end
      def process_loop
        loop do
          begin
            rec = get()
            data.out.write(rec)
            data.out.flush
            dest_report_new_data
          rescue Errno::EWOULDBLOCK
            source_resume(true) or source_wait
          rescue Errno::EINTR
            break
          rescue EOFError,StopIteration
            data.out.close_write
            source_resume(nil) if source
            break
          end
        end
      end
    end

  end
end

module RIO
  module Cmd
    class FromInput < From
      def initialize(rd)
        super(rd)
      end
      def get() data.in.readline end
    end

    class FromProc < From
      BUF_LEN = 128
      def source_wait() IO.select([data.in]) end
      def get() data.in.read_nonblock(BUF_LEN) end
    end

    class FromEnum < FromInput
      def get() data.in.next end
    end

    class FromFile < FromInput
      def initialize(filename)
        super(File.open(filename))
      end
    end

  end
end

module RIO
  module Cmd

    class FibPipeProc < FromProc
      def initialize(*args)
        super(IO.popen(*args))
        @to_proc = ToProc.new(data.in)
      end
      def _fiber_init(trail)
        trail.unshift(@to_proc)
        super(trail)
      end
    end

    class FibSourceProc < FromInput
      def initialize(*args)
        super(IO.popen(*args))
      end
    end

  end
end

module RIO
  module Cmd

    class FibCmd
      def initialize(*args)
        from = FromInput.new
        pcmd = RIO::Cmd::FibPipeProc.new(*args)
        to_pipe = ToPipe.new
      end
    end

  end
end

__END__
