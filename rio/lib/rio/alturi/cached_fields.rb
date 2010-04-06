module Alt
  module URI
    class CachedFields
      DEPENDS = {
        :uri => [:scheme,:authority,:path,:query,:fragment],
        :authority => [:userinfo,:host,:port]
      }

      def self.flatten_depends_list(depends,list)
        flat = []
        list.each do |sym|
          flat << sym
          if depends[sym]
            flat += flatten_depends_list(depends,depends[sym])
          end
        end
        flat
      end

      def self.gen_sullies(depends)
        sullies = {}
        depends.each do |key,ary|
          list = flatten_depends_list(depends,ary)
          list.each do |k|
            sullies[k] ||= []
            sullies[k] << key
          end
          sullies[key] ||= []
          sullies[key] += list
        end
        sullies
      end
      SULLIES = gen_sullies(DEPENDS)

      def initialize
        @store = Hash.new
      end

      def [](key)
        @store[key]
      end

      def clear_key(key)
        if klist = SULLIES[key]
          klist.each do |k|
            @store.delete(k)
          end
        end
        @store.delete(key)
      end 
      
      
      
      def []=(key,val)
        clear_key(key)
        @store[key] = val
      end

      def has_key?(arg)
        @store.has_key?(arg)
      end
      def inspect
        @store.inspect
      end
    end
  end

end
