require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'


module RioTest
  class ModSuite
    attr_reader :utmod_name,:root_mod
    def initialize(utmod_name,root_mod = RIO)
      @utmod_name = utmod_name
      @root_mod = root_mod
      @suite = nil
    end
    def test_dir
      'qp/' + root_mod.to_s.downcase + '_' + utmod_name.to_s.downcase
    end
    def run
      wd = Dir.pwd
      rio(test_dir).delete!.mkpath.chdir
      # p "ModSuite.run pwd=#{Dir.pwd}"
      ste = self.suite
      Test::Unit::UI::Console::TestRunner.run(ste)
      Dir.chdir(wd)
    end
    def topmod
      root_mod.module_eval(utmod_name)
    end
    def utmod
      unless topmod.const_defined?(:UnitTest)
        topmod.const_set(:UnitTest,Module.new)
      end
      topmod.module_eval(:UnitTest)
    end
    def mods
      utmod.constants
    end
    def modlist
      clsdef = %{
        class TestCase < Test::Unit::TestCase
          include Tests
        end
      }
      mlist = []
      mods.each do |modstr|
        m = utmod.module_eval(modstr).module_eval(clsdef)
        #Test::Unit::UI::Console::TestRunner.run(mod.module_eval(:TestSuite))  if $0 == file
        #Test::Unit::UI::Console::TestRunner.run(m)
        mlist << m
      end
      mlist
    end

    def self.suite(utmod_name,root_mod = RIO)
      ms = new(utmod_name,root_mod)
      ms.create_modsuite
    end

    def create_modsuite
      suite = Test::Unit::TestSuite.new(topmod.to_s)
      modlist.each do |m|
        suite << m.suite
      end
      suite
    end
    def <<(ste)
      self.suite << ste
    end
    def add(utmod_name,root_mod = RIO)
      self.suite << RioTest::ModSuite.new(utmod_name,root_mod).suite
    end


    def suite
      @suite ||= create_modsuite
    end

  end



  
  def define_utmod(utmod_name,root_mod = RIO)

    topmod = root_mod.module_eval(utmod_name)
    utmod = topmod.module_eval('UnitTest')
    
    mods = utmod.constants
    p mods
    
    clsdef = %{
      class TestCase < Test::Unit::TestCase
        include Tests
      end
    }
    modlist = []
    mods.each do |modstr|
      m = utmod.module_eval(modstr).module_eval(clsdef)
      #Test::Unit::UI::Console::TestRunner.run(mod.module_eval(:TestSuite))  if $0 == file
      #Test::Unit::UI::Console::TestRunner.run(m)
      modlist << m
    end
    modlist
  end
  module_function :define_utmod

  def create_modsuite(utmod_name,root_mod = RIO)
    topmod = root_mod.module_eval(utmod_name)
    suite = Test::Unit::TestSuite.new(topmod.to_s)
    modlist = RioTest.define_utmod(utmod_name,root_mod)
    modlist.each do |m|
      suite << m.suite
    end
    suite
  end
  module_function :create_modsuite
  
  
end

