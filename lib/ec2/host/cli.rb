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
        :aliases => %w[-r --usage -u],
        :type => :array,
        :desc => "role"
      option :role1,
        :aliases => %w[--r1 --usage1 --u1], # hmm, -r1 is not suppored by thor
        :type => :array,
        :desc => "role1, the 1st part of role delimited by #{Config.role_tag_delimiter}"
      option :role2,
        :aliases => %w[--r2 --usage2 --u2],
        :type => :array,
        :desc => "role2, the 2nd part of role delimited by #{Config.role_tag_delimiter}"
      option :role3,
        :aliases => %w[--r3 --usage3 --u3],
        :type => :array,
        :desc => "role3, the 3rd part of role delimited by #{Config.role_tag_delimiter}"
      option :instance_id,
        :type => :array,
        :desc => "instance_id"
      option :state,
        :type => :array,
        :desc => "state"
      option :monitoring,
        :type => :array,
        :desc => "monitoring"
      Config.optional_options.each do |opt, tag|
        option opt, :type => :array, :desc => opt
      end
      option :private_ip,
        :aliases => %w[--ip],
        :type => :boolean,
        :desc => 'show private ip address instead of hostname'
      option :public_ip,
        :type => :boolean,
        :desc => 'show public ip address instead of hostname'
      option :info,
        :aliases => %w[-i],
        :type => :boolean,
        :desc => "show host info"
      option :line_delimited_json,
        :aliases => %w[-j],
        :type => :boolean,
        :desc => "show host info in line delimited json"
      option :json,
        :type => :boolean,
        :desc => "show host info in json"
      option :pretty_json,
        :type => :boolean,
        :desc => "show host info in pretty json"
      option :debug,
        :type => :boolean,
        :desc => "debug mode"
      def get_hosts
        hosts = EC2::Host.new(condition)
        if options[:info]
          hosts.each do |host|
            $stdout.puts host.info
          end
        elsif options[:line_delimited_json]
          hosts.each do |host|
            $stdout.puts host.to_hash.to_json
          end
        elsif options[:json]
          $stdout.puts hosts.map(&:to_hash).to_json
        elsif options[:pretty_json]
          $stdout.puts JSON.pretty_generate(hosts.map(&:to_hash))
        elsif options[:private_ip]
          hosts.each do |host|
            $stdout.puts host.private_ip_address
          end
        elsif options[:public_ip]
          hosts.each do |host|
            $stdout.puts host.public_ip_address
          end
        else
          hosts.each do |host|
            $stdout.puts host.hostname
          end
        end
      end

      private

      def condition
        return @condition if @condition
        _condition = HashUtil.except(options, :info, :line_delimited_json, :json, :pretty_json, :debug, :private_ip, :public_ip)
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
