require 'forwardable'
require 'hashie/mash'

class EC2
  class Host
    # Represents each host
    class HostData < Hashie::Mash
      # :hostname, # tag:Name or hostname part of private_dns_name
      # :roles,    # tag:Roles.split(',') such as web:app1,db:app1
      # :region,   # ENV['AWS_REGION'],
      # :instance, # Aws::EC2::Types::Instance itself
      #
      # and OPTIONAL_ARRAY_TAGS, OPTIONAL_STRING_TAGS

      extend Forwardable
      def_delegators :instance,
        :instance_id,
        :private_ip_address,
        :public_ip_address,
        :launch_time,
        :state,
        :monitoring

      alias_method :ip, :private_ip_address
      alias_method :start_date, :launch_time
      def usages; roles; end

      def self.initialize(instance)
        d = self.new
        d.instance = instance
        d.set_hostname
        d.set_roles
        d.set_region
        d.set_string_tags
        d.set_array_tags
        d
      end

      # match with condition or not
      #
      # @param [Hash] condition search parameters
      def match?(condition)
        return false unless role_match?(condition)
        condition = HashUtil.except(condition,
          :role, :role1, :role2, :role3,
          :usage, :usage1, :usage2, :usage3
        )
        condition.each do |key, values|
          if self.send(key).is_a?(Array)
            return false unless self.send(key).find {|v| values.include?(v) }
          else
            return false unless values.include?(self.send(key))
          end
        end
        true
      end

      def inspect
        sprintf "#<Aws::Host::HostData %s>", info
      end

      def info
        if hostname and status and roles and tags and service
          # special treatment for DeNA ;)
          sprintf "%s:%s(%s)[%s]{%s}", \
            hostname, status, roles.join(' '), tags.join(' '), service
        else
          HashUtil.except(self, :instance).to_s
        end
      end

      # private

      def role_match?(condition)
        # usage is an alias of role
        if role = (condition[:role] || condition[:usage])
          role1, role2, role3 = role.first.split(':')
        else
          role1 = (condition[:role1] || condition[:usage1] || []).first
          role2 = (condition[:role2] || condition[:usage2] || []).first
          role3 = (condition[:role3] || condition[:usage3] || []).first
        end
        if role1
          return false unless self.roles.find {|role| role.match?(role1, role2, role3) }
        end
        true
      end

      def set_hostname
        self.hostname = find_string_tag(Config.hostname_tag)
        self.hostname = instance.private_dns_name.split('.').first if self.hostname.empty?
      end

      def set_roles
        roles  = find_array_tag(Config.roles_tag)
        self.roles = roles.map {|role| EC2::Host::RoleData.initialize(role) }
      end

      def set_region
        self.region = Config.aws_region
      end

      def set_string_tags
        Config.optional_string_tags.each do |tag|
          field = StringUtil.underscore(tag)
          self[field] = find_string_tag(tag)
        end
      end

      def set_array_tags
        Config.optional_array_tags.each do |tag|
          field = StringUtil.underscore(tag)
          self[field] = find_array_tag(tag)
        end
      end

      def find_string_tag(key)
        v = instance.tags.find {|tag| tag.key == key }
        v ? v.value : ''
      end

      def find_array_tag(key)
        v = instance.tags.find {|tag| tag.key == key }
        v ? v.value.split(ARRAY_TAG_DELIMITER) : []
      end
    end
  end
end
