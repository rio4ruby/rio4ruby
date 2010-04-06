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
        # $stdout.printf("\n%s%-9s resumes-> %-12s (%s) ... ","  "*@@depth,self.fib.name,source.fib.name,args.join(","))
        @@depth += 1
        source.resume(*args)
      end
      def fiber_yield(*args)
        @@depth -= 1
        # $stdout.printf("%s%s yields (%s)\n","  "*@@depth,self.fib.name,args.join(","))
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
        #data.out.flush
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
            data.out.close_write if duplex?
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
        # @to_proc = ToProc.new(data.in)
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
ior = File.open('lines10.txt')
iow = $stdout
#input = RIO::Cmd::FromInput.new(ior)
#input = RIO::Cmd::FromFile.new('lines10.txt')
input = RIO::Cmd::FromEnum.new(ior.to_enum)
#to_out = RIO::Cmd::ToStdout.new
output = RIO::Cmd::ToOutput.new($stdout)
cat = RIO::Cmd::FibPipeProc.new(['cat','-n'],'w+')
cat2 = RIO::Cmd::FibPipeProc.new(['cat','-n'],'w+')

output.resume [cat,cat2,input]
puts
puts

ls = RIO::Cmd::FibSourceProc.new(['ls','-l'])
grepc = RIO::Cmd::FibPipeProc.new(['grep','2010-02-06'],'w+')
output = RIO::Cmd::ToOutput.new($stdout)

output.resume [grepc,ls]

__END__
__END__

ls = RIO::Cmd::FibSourceProc.new(['ls','-l'])
output = RIO::Cmd::ToOutput.new($stdout)
output.resume [ls]


__END__
cat = RIO::Cmd::FibPipeProc.new(['cat','-n'],'w+')

p '--------------------------------------------------------->>>>>>>>>>>'
to_stdout.resume [cat,from_file]


__END__
from_file = RIO::Cmd::FromFile.new("lines10.txt")
cat = RIO::Cmd::FibPipeProc.new(['cat','-n'],'w+')
to_stdout = RIO::Cmd::ToStdout.new

p '--------------------------------------------------------->>>>>>>>>>>'
to_stdout.resume [cat,from_file]


__END__
from_file = FromFile.new("lines10.txt")

ioproc = IO.popen(['cat','-n'],'w+')
to_proc = ToProc.new(ioproc)
from_proc = FromProc.new(ioproc)

ioproc2 = IO.popen(['cat','-n'],'w+')
to_proc2 = ToProc.new(ioproc2)
from_proc2 = FromProc.new(ioproc2)

to_stdout = ToStdout.new


to_stdout.resume [from_proc,to_proc,from_proc2,to_proc2,from_file]


__END__
from_proc = FromProc.new(IO.popen(['ls','-l']))
fpi = ToStdout.new
fpi.resume [from_proc]


__END__
#from_file = FromFile.new("lines10.txt")
from_file = FromFile.new("lines10.txt")
#from_procy = FromProc.new(IO.popen(['yes','what is the deal']))
from_proc = FromProcSelect.new(['cat','-n'])
to_stdout = ToStdout.new


to_stdout.resume [from_proc,from_file]


__END__
feeder = FromFile.new("lines10.txt")
fpi = ToStdout.new
fpi.resume [feeder]

__END__


feeder = FromFile.new("lines10.txt")
fpi = ToStdout.new
fpi.resume [feeder]

__END__
