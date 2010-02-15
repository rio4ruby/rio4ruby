require 'forwardable'

module RIO
  module Fwd
    extend Forwardable
    def fwd(target,*args)
      self.module_exec(target,args) do |targ,a|
        a.each do |sym|
          def_delegator targ, sym
          def_delegator targ, (sym.to_s+"=").to_sym
        end
      end
    end
  end
end
