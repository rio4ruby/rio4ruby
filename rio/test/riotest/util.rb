
module RioTest
  module Util
    def build_mod_testcase_class(sym)
      self.module_eval %{
        module #{sym}
          class TestCase < Test::Unit::TestCase
            include Tests
          end  
        end
      }
    end
    module_function :build_mod_testcase_class
  end
end




