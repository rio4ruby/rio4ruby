require "rio"
require "rio/state"
require "test/unit"
class RIO::State::BaseTest < Test::Unit::TestCase
  
  def setup
    super
  end

  def test_ensure_rio
    assert_instance_of(RIO::Rio,rio("apath"))
     
  end  
  
  def teardown
    super
  end
end