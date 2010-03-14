require 'rio'

def run_tests(test_dir,test_top = '/loc/work/q/test',&block)
  rio(test_top).mkdir.chdir do
    rio(test_dir).delete!.mkdir.chdir do
      yield
    end
  end
end
