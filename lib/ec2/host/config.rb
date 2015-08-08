require 'dotenv'
Dotenv.load

class EC2
  class Host
    class Config
      def self.config_file
        ENV.fetch('EC2_HOST_CONFIG_FILE', '/etc/sysconfig/ec2-host')
      end

      def self.aws_access_key_id
        ENV['AWS_ACCESS_KEY_ID'] || config.fetch('AWS_ACCESS_KEY_ID')
      end

      def self.aws_secret_access_key
        ENV['AWS_SECRET_ACCESS_KEY'] || config.fetch('AWS_SECRET_ACCESS_KEY')
      end

      def self.aws_region
        ENV['AWS_REGION'] || config.fetch('AWS_REGION')
      end

      def self.log_level
        ENV['LOG_LEVEL'] || config.fetch('LOG_LEVEL', 'info')
      end

      def self.hostname_tag
        ENV['HOSTNAME_TAG'] || config.fetch('HOSTNAME_TAG', 'Name')
      end

      def self.roles_tag
        ENV['ROLES_TAG'] || config.fetch('ROLES_TAG', 'Roles')
      end

      def self.optional_array_tags
        @optional_array_tags ||= (ENV['OPTIONAL_ARRAY_TAGS'] || config.fetch('OPTIONAL_ARRAY_TAGS', '')).split(',')
      end

      def self.optional_string_tags
        @optional_string_tags ||= (ENV['OPTIONAL_STRING_TAGS'] || config.fetch('OPTIONAL_STRING_TAGS', '')).split(',')
      end

      # private

      def self.optional_array_options
        @optional_array_options ||= Hash[optional_array_tags.map {|tag|
          [StringUtil.singularize(StringUtil.underscore(tag)), tag]
        }]
      end

      def self.optional_string_options
        @optional_string_options ||= Hash[optional_string_tags.map {|tag|
          [StringUtil.underscore(tag), tag]
        }]
      end

      def self.optional_options
        @optional_options ||= optional_array_options.merge(optional_string_options)
      end

      def self.config
        return @config if @config
        @config = {}
        File.readlines(config_file).each do |line|
          next if line.start_with?('#')
          key, val = line.chomp.split('=', 2)
          @config[key] = val
        end
        @config
      end
    end
  end
end
