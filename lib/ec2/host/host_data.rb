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
        @roles = roles.map {|role| EC2::Host::RoleData.build(role) }
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

      def instance_id
        instance.instance_id
      end

      def instance_type
        instance.instance_type
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

      def placement
        instance.placement
      end

      def availability_zone
        instance.placement.availability_zone
      end

      def tenancy
        instance.placement.tenancy
      end

      def instance_lifecycle
        instance.instance_lifecycle
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

      def stopped?
        state == "stopped"
      end

      def running?
        state == "running"
      end

      def pending?
        state == "pending"
      end

      def spot?
        instance_lifecycle == 'spot'
      end
      alias :spot :spot?

      def dedicated?
        tenancy == 'dedicated'
      end
      alias :dedicated :dedicated?

      # match with condition or not
      #
      # @param [Hash] condition search parameters
      def match?(condition)
        if condition[:state].nil?
          return false if (terminated? or shutting_down?)
        end
        return false unless role_match?(condition)
        return false unless instance_match?(condition)
        true
      end

      def to_hash
        params = {
          "hostname" => hostname,
          "roles" => roles,
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
          "region" => region,
          "availability_zone" => availability_zone,
          "instance_id" => instance_id,
          "instance_type" => instance_type,
          "private_ip_address" => private_ip_address,
          "public_ip_address" => public_ip_address,
          "launch_time" => launch_time,
          "state" => state,
          "monitoring" => monitoring,
          "spot" => spot,
        )
      end

      def info
        if self.class.display_short_info?
          info = "#{hostname}:#{status}"
          info << "(#{roles.join(',')})" unless roles.empty?
          info << "[#{tags.join(',')}]" unless tags.empty?
          info << "{#{service}}" unless service.empty?
          info
        else
          to_hash.to_s
        end
      end

      def inspect
        sprintf "#<Aws::Host::HostData %s>", info
      end

      private

      def find_string_tag(key)
        v = instance.tags.find {|tag| tag.key == key }
        v ? v.value : ''
      end

      def find_array_tag(key)
        v = instance.tags.find {|tag| tag.key == key }
        v ? v.value.split(Config.array_tag_delimiter) : []
      end

      def role_match?(condition)
        # usage is an alias of role
        if role = (condition[:role] || condition[:usage])
          role.any? do |r|
            parts = r.split(Config.role_tag_delimiter, Config.role_max_depth)
            next true if parts.compact.empty? # no role conditions
            roles.find {|role| role.match?(*parts) }
          end
        else
          parts = 1.upto(Config.role_max_depth).map do |i|
            condition["role#{i}".to_sym] || condition["usage#{i}".to_sym]
          end
          return true if parts.compact.empty? # no role conditions
          roles.find {|role| role.match?(*parts) }
        end
      end

      def instance_match?(condition)
        excepts = [:role, :usage]
        1.upto(Config.role_max_depth).each {|i| excepts << "role#{i}".to_sym }
        1.upto(Config.role_max_depth).each {|i| excepts << "usage#{i}".to_sym }
        condition = HashUtil.except(condition, *excepts)
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
      def instance_variable_recursive_get(key)
        v = self
        key.to_s.split('.').each {|k| v = v.send(k) }
        v
      end

      # compatibility with dino-host
      #
      # If Service,Status,Tags tags are defined
      #
      #     OPTIONAL_STRING_TAGS=Service,Status
      #     OPTIONAL_ARRAY_TAGS=Tags
      #
      # show in short format, otherwise, same with to_hash.to_s
      def self.display_short_info?
        return @display_short_info unless @display_short_info.nil?
        @display_short_info = (method_defined?(:service) and method_defined?(:status) and method_defined?(:tags))
      end
    end
  end
end
