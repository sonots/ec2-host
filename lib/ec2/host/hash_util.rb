class EC2
  class Host
    module HashUtil
      def self.except(hash, *keys)
        hash = hash.dup
        keys.each {|key| hash.delete(key) }
        hash
      end
    end
  end
end
