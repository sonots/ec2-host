class EC2
  class Host
    RoleData = Struct.new(
      :role1, :role2, :role3
    )

    # Represents each role
    class RoleData
      def self.initialize(role)
        role1, role2, role3 = role.split(ROLE_TAG_DELIMITER)
        self.new(role1, role2, role3)
      end

      # @return [String] something like "admin:jenkins:slave"
      def role
        @role ||= [role1, role2, role3].compact.reject(&:empty?).join(ROLE_TAG_DELIMITER)
      end
      alias :to_s :role

      # @return [Array] something like ["admin", "admin:jenkins", "admin:jenkins:slave"]
      def uppers
        uppers = [RoleData.new(role1)]
        uppers << RoleData.new(role1, role2) if role2 and !role2.empty?
        uppers << RoleData.new(role1, role2, role3) if role3 and !role3.empty?
        uppers
      end

      def match?(role1, role2 = nil, role3 = nil)
        if role3
          role1 == self.role1 and role2 == self.role2 and role3 == self.role3
        elsif role2
          role1 == self.role1 and role2 == self.role2
        else
          role1 == self.role1
        end
      end

      # Equality
      #
      #     Role::Data.new('admin') == Role::Data.new('open', 'admin') #=> true
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
        sprintf "#<EC2::Host::RoleData %s>", role
      end
    end
  end
end
