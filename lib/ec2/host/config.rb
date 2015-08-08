require 'dotenv'
Dotenv.load

class EC2
  class Host
    class Config
      def self.config_file
        ENV.fetch('EC2_HOST_CONFIG_FILE', '/etc/sysconfig/ec2-host')
      end

      def self.aws_region
        ENV['AWS_REGION'] || config.fetch('AWS_REGION')
      end

      def self.aws_profile
        ENV['AWS_PROFILE'] || config.fetch('AWS_PROFILE', 'default')
      end

      def self.aws_access_key_id
        ENV['AWS_ACCESS_KEY_ID'] || config.fetch('AWS_ACCESS_KEY_ID', nil)
      end

      def self.aws_secret_access_key
        ENV['AWS_SECRET_ACCESS_KEY'] || config.fetch('AWS_SECRET_ACCESS_KEY', nil)
      end

      # this is not an official aws sdk environment variable
      def self.aws_credentials_file
        ENV['AWS_CREDENTIALS_FILE'] || config.fetch('AWS_CREDENTIALS_FILE', nil)
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

      def self.aws_credentials
        if aws_access_key_id and aws_secret_access_key
          Aws::Credentials.new(aws_access_key_id, aws_secret_access_key)
        else
          Aws::SharedCredentials.new(profile_name: aws_profile, path: aws_credentials_file)
        end
      end

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
