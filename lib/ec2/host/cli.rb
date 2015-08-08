require 'thor'
require 'ec2-host'

class EC2
  class Host
    class CLI < Thor
      default_command :get_hosts

      desc 'get-hosts', 'Search EC2 hosts (default)'
      option :hostname,
        :aliases => '-h',
        :type => :array,
        :desc => "name or private_dns_name"
      option :role,
        :aliases => %w[--usage],
        :type => :array,
        :desc => "role"
      option :role1,
        :aliases => %w[--r1 --usage1 --u1], # hmm, -r1 is not suppored by thor
        :type => :array,
        :desc => "role1, the 1st part of role delimited by #{ROLE_TAG_DELIMITER}"
      option :role2,
        :aliases => %w[--r2 --usage2 --u2],
        :type => :array,
        :desc => "role2, the 2nd part of role delimited by #{ROLE_TAG_DELIMITER}"
      option :role3,
        :aliases => %w[--r3 --usage3 --u3],
        :type => :array,
        :desc => "role3, the 3rd part of role delimited by #{ROLE_TAG_DELIMITER}"
      Config.optional_options.each do |opt, tag|
        option opt, :type => :array, :desc => opt
      end
      option :info,
        :aliases => %w[-i],
        :type => :boolean,
        :desc => "show host info, not only hostname"
      option :debug,
        :type => :boolean,
        :desc => "debug mode"
      def get_hosts
        if options[:info]
          EC2::Host.new(condition).each do |host|
            $stdout.puts host.info
          end
        else
          EC2::Host.new(condition).each do |host|
            $stdout.puts host.hostname
          end
        end
      end

      private

      def condition
        return @condition if @condition
        _condition = HashUtil.except(options, :info, :debug)
        @condition = {}
        _condition.each do |key, val|
          if tag = Config.optional_options[key.to_s]
            field = StringUtil.underscore(tag)
            @condition[field.to_sym] = val
          else
            @condition[key.to_sym] = val
          end
        end
        if options[:debug]
          $stderr.puts(options: options)
          $stderr.puts(condition: @condition)
        end
        @condition
      end
    end
  end
end
