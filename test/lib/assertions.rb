module RIOTest
  module Assertions
    def assert!(a,msg="negative assertion")
      assert((!(a)),msg)
    end
  end
end
