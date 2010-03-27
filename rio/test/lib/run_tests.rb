require 'rio'

module RunTests
  def run_tests(test_dir,test_top = '/loc/work/q/test',&block)
    rio(test_top).mkdir.chdir do
      rio(test_dir).delete!.mkdir.chdir do
        yield
      end
    end
  end
  module_function :run_tests
end

def run_tests(*args,&block)
  RunTests.run_tests(*args,&block)
end

