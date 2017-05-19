class EC2
  class Host
    # Represents each role
    class RoleData
      # Initialize role data with role parts
      #
      #     RoleData.new('admin', 'jenkins', 'slave')
      #
      # @param [Array] role_parts such as ['admin', 'jenkins', 'slave']
      def initialize(*role_parts)
        @role_parts = role_parts
      end

      # Create a role data with role delimiter by Config.role_tag_delimiter
      #
      #     RoleData.build('admin:jenkins:slave')
      #
      # @param [String] role such as "admin:jenkins:slave"
      def self.build(role)
        role_parts = role.split(Config.role_tag_delimiter, Config.role_max_depth)
        new(*role_parts)
      end

      # @return [String] something like "admin:jenkins:slave"
      def role
        @role ||= @role_parts.compact.reject(&:empty?).join(Config.role_tag_delimiter)
      end
      alias :to_s :role

      1.upto(Config.role_max_depth).each do |i|
        define_method("role#{i}") do
          @role_parts[i-1]
        end
      end

      # @return [Array] something like ["admin", "admin:jenkins", "admin:jenkins:slave"]
      def uppers
        role_parts = @role_parts.dup
        upper_role_parts = []
        upper_role_parts << [role_parts.shift]
        role_parts.each do |role_part|
          break if role_part.nil? or role_part.empty?
          upper_role_parts << [*(upper_role_parts.last), role_part]
        end
        upper_role_parts.map {|role_parts| RoleData.new(*role_parts) }
      end

      # Check whether given role parts matches with this role data object
      #
      #     RoleData.new('admin', 'jenkins', 'slave').match?('admin') #=> true
      #     RoleData.new('admin', 'jenkins', 'slave').match?('admin', 'jenkins') #=> true
      #     RoleData.new('admin', 'jenkins', 'slave').match?('admin', 'jenkins', 'slave') #=> true
      #     RoleData.new('admin', 'jenkins', 'slave').match?('admin', 'jenkins', 'master') #=> false
      #     RoleData.new('admin', 'jenkins', 'slave').match?(nil, 'jenkins') #=> true
      #     RoleData.new('admin', 'jenkins', 'slave').match?(nil, nil, 'slave') #=> true
      #
      #     RoleData.new('foo', 'a').match?(['foo', 'bar']) #=> true
      #     RoleData.new('bar', 'a').match?(['foo', 'bar']) #=> true
      #
      #     RoleData.new('foo', 'a').match?(['foo', 'bar'], ['a', 'b']) #=> true
      #     RoleData.new('foo', 'a').match?(['foo', 'bar'], ['a', 'b']) #=> true
      #     RoleData.new('bar', 'b').match?(['foo', 'bar'], ['a', 'b']) #=> true
      #     RoleData.new('bar', 'b').match?(['foo', 'bar'], ['a', 'b']) #=> true
      #
      # @param [Array] role_parts such as ["admin", "jenkins", "slave"]
      def match?(*role_parts)
        indexes = role_parts.map.with_index {|part, i| part ? i : nil }.compact
        indexes.all? {|i| Array(role_parts[i]).include?(@role_parts[i]) }
      end

      # Equality
      #
      #     RoleData.new('admin') == RoleData.new('admin') #=> true
      #     RoleData.new('admin', 'jenkin') == "admin:jenkins" #=> true
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
