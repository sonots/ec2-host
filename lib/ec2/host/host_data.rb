require 'json'

class EC2
  class Host
    # Represents each host
    class HostData
      attr_reader :instance

      # :hostname, # tag:Name or hostname part of private_dns_name
      # :roles,    # tag:Roles.split(',') such as web:app1,db:app1
      # :region,   # ENV['AWS_REGION'],
      # :instance, # Aws::EC2::Types::Instance itself
      #
      # and OPTIONAL_ARRAY_TAGS, OPTIONAL_STRING_TAGS
      def initialize(instance)
        @instance = instance
      end

      def hostname
        return @hostname if @hostname
        @hostname = find_string_tag(Config.hostname_tag)
        @hostname = instance.private_dns_name.split('.').first if @hostname.empty?
        @hostname
      end

      def roles
        return @roles if @roles
        roles = find_array_tag(Config.roles_tag)
        @roles = roles.map {|role| EC2::Host::RoleData.initialize(role) }
      end

      def region
        Config.aws_region
      end

      Config.optional_string_tags.each do |tag|
        field = StringUtil.underscore(tag)
        define_method(field) do
          instance_variable_get("@#{field}") || instance_variable_set("@#{field}", find_string_tag(tag))
        end
      end

      Config.optional_array_tags.each do |tag|
        field = StringUtil.underscore(tag)
        define_method(field) do
          instance_variable_get("@#{field}") || instance_variable_set("@#{field}", find_array_tag(tag))
        end
      end

      private def find_string_tag(key)
        v = instance.tags.find {|tag| tag.key == key }
        v ? v.value : ''
      end

      private def find_array_tag(key)
        v = instance.tags.find {|tag| tag.key == key }
        v ? v.value.split(Config.array_tag_delimiter) : []
      end

      def instance_id
        instance.instance_id
      end

      def private_ip_address
        instance.private_ip_address
      end

      def public_ip_address
        instance.public_ip_address
      end

      def launch_time
        instance.launch_time
      end

      def state
        instance.state.name
      end

      def monitoring
        instance.monitoring.state
      end

      # compatibility with dino-host
      def ip
        private_ip_address
      end

      # compatibility with dino-host
      def start_date
        launch_time
      end

      # compatibility with dino-host
      def usages
        roles
      end

      def terminated?
        state == "terminated"
      end

      def shutting_down?
        state == "shutting-down"
      end

      def stopping?
        state == "stopping"
      end

      def stopped
        state == "stopped"
      end

      def running?
        state == "running"
      end

      def pending?
        state == "pending"
      end

      # match with condition or not
      #
      # @param [Hash] condition search parameters
      def match?(condition)
        return false if !condition[:state] and (terminated? or shutting_down?)
        return false unless role_match?(condition)
        return false unless instance_match?(condition)
        true
      end

      private def role_match?(condition)
        # usage is an alias of role
        if role = (condition[:role] || condition[:usage])
          role1, role2, role3 = role.first.split(':')
        else
          role1 = (condition[:role1] || condition[:usage1] || []).first
          role2 = (condition[:role2] || condition[:usage2] || []).first
          role3 = (condition[:role3] || condition[:usage3] || []).first
        end
        if role1
          return false unless roles.find {|role| role.match?(role1, role2, role3) }
        end
        true
      end

      private def instance_match?(condition)
        condition = HashUtil.except(condition, :role, :role1, :role2, :role3, :usage, :usage1, :usage2, :usage3)
        condition.each do |key, values|
          v = instance_variable_recursive_get(key)
          if v.is_a?(Array)
            return false unless v.find {|_| values.include?(_) }
          else
            return false unless values.include?(v)
          end
        end
        true
      end

      # "instance.instance_id" => self.instance.instance_id
      private def instance_variable_recursive_get(key)
        v = self
        key.to_s.split('.').each {|k| v = v.send(k) }
        v
      end

      def to_hash
        params = {
          "hostname" => hostname,
          "roles" => roles,
          "region" => region,
        }
        Config.optional_string_tags.each do |tag|
          field = StringUtil.underscore(tag)
          params[field] = send(field)
        end
        Config.optional_array_tags.each do |tag|
          field = StringUtil.underscore(tag)
          params[field] = send(field)
        end
        params.merge!(
          "instance_id" => instance_id,
          "private_ip_address" => private_ip_address,
          "public_ip_address" => public_ip_address,
          "launch_time" => launch_time,
          "state" => state,
          "monitoring" => monitoring,
        )
      end

      # compatibility with dono-host
      #
      # If Service,Status,Tags tags are defined
      #
      #     OPTIONAL_STRING_TAGS=Service,Status
      #     OPTIONAL_ARRAY_TAGS=Tags
      #
      # show in short format, otherwise, same with to_hash.to_s
      def self.display_short_info?
        return @display_short_info unless @display_short_info.nil?
        @display_short_info = method_defined?(:service) and method_defined?(:status) and method_defined?(:tags)
      end

      def info
        if self.class.display_short_info?
          info = "#{hostname}:#{status}"
          info << "(#{roles.join(' ')})" unless roles.empty?
          info << "[#{tags.join(' ')}]" unless tags.empty?
          info << "{#{service}}" unless service.empty?
          info
        else
          to_hash.to_s
        end
      end

      def inspect
        sprintf "#<Aws::Host::HostData %s>", info
      end
    end
  end
end
