module RIO
  module Fwd
    def fwd_reader(target, method)
      line_no = __LINE__
      str = %{
        def #{method}(*args, &block)
           #{target}.__send__(:#{method}, *args, &block)
        end
      }
      module_eval(str,__FILE__,line_no)
    end
    def fwd_readers(target, *methods)
      methods.each do |method|
        fwd_reader target, method
      end
    end
    
    def fwd_writer(target, method)
      line_no = __LINE__
      str = %{
        def #{method}=(*args, &block)
           #{target}.__send__(:#{method}=, *args, &block)
        end
      }
      module_eval(str,__FILE__,line_no)
    end
    def fwd_writers(target, *methods)
      methods.each do |method|
        fwd_writer target, method
      end
    end

    def fwd(target,*methods)
      fwd_readers target, *methods
      fwd_writers target, *methods
    end
  end
end
