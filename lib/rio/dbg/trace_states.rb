
module RIO
  module DBG
    def trace_states(tf=true,&block)
      old_trace_states = $trace_states
      begin
        $trace_states = tf
        yield
      ensure
        $trace_states = old_trace_states
      end
    end
    module_function :trace_states
  end
end



