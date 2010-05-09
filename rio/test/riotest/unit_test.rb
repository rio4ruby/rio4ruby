require 'test/unit'


module RioTest

  
  def define_utmod(utmod_name,root_mod = RIO)
    utmod = root_mod.module_eval(utmod_name).module_eval('UnitTest')
    
    mods = utmod.constants
    p mods
    
    clsdef = %{
      class TestCase < Test::Unit::TestCase
        include Tests
      end
    }
    mods.each do |modstr|
      utmod.module_eval(modstr).module_eval(clsdef)
    end
  end
  module_function :define_utmod



  
  
end

