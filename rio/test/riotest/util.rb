
module RioTest
  module Util
    def smap(a)
      a.map(&:to_s)
    end

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




