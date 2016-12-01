class EC2
  class Host
    # Represents each role
    class RoleData
      def initialize(*parts)
        @parts = parts
      end

      def self.build(role)
        parts = role.split(Config.role_tag_delimiter, Config.role_max_depth)
        new(*parts)
      end

      # @return [String] something like "admin:jenkins:slave"
      def role
        @role ||= @parts.compact.reject(&:empty?).join(Config.role_tag_delimiter)
      end
      alias :to_s :role

      1.upto(Config.role_max_depth).each do |i|
        define_method("role#{i}") do
          @parts[i-1]
        end
      end

      # @return [Array] something like ["admin", "admin:jenkins", "admin:jenkins:slave"]
      def uppers
        parts = @parts.dup
        upper_parts = []
        upper_parts << [parts.shift]
        parts.each do |part|
          break if part.nil? or part.empty?
          upper_parts << [*(upper_parts.last), part]
        end
        upper_parts.map {|parts| RoleData.new(*parts) }
      end

      def match?(*parts)
        (Config.role_max_depth-1).downto(0).each do |i|
          next unless parts[i]
          return @parts[0..i] == parts[0..i]
        end
      end

      # Equality
      #
      #     Role::Data.new('admin') == Role::Data.new('admin') #=> true
      #     Role::Data.new('admin', 'jenkin') == "admin:jenkins" #=> true
      #
      # @param [Object] other
      def ==(other)
        case other
        when String
          self.role == other
        when EC2::Host::RoleData
          super(other)
        else
          false
        end
      end

      def inspect
        "\"#{to_s}\""
      end
    end
  end
end
