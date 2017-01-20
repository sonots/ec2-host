require 'ec2-host'
require 'optparse'

class EC2
  class Host
    class CLI
      attr_reader :options

      def initialize(argv = ARGV)
        @options = parse_options(argv)
      end

      def parse_options(argv = ARGV)
        op = OptionParser.new

        self.class.module_eval do
          define_method(:usage) do |msg = nil|
            puts op.to_s
            puts "error: #{msg}" if msg
            exit 1
          end
        end

        opts = {
          state: ["running"]
        }

        op.on('--hostname one,two,three', Array, "name or private_dns_name") {|v|
          opts[:hostname] = v
        }
        op.on('-r', '--role one,two,three', Array, "role") {|v|
          opts[:role] = v
        }
        1.upto(Config.role_max_depth).each do |i|
          op.on("--r#{i}", "--role#{i} one,two,three", Array, "role#{i}, #{i}th part of role delimited by #{Config.role_tag_delimiter}") {|v|
            opts["role#{i}".to_sym] = v
          }
        end
        op.on('--instance-id one,two,three', Array, "instance_id") {|v|
          opts[:instance_id] = v
        }
        op.on('--state one,two,three', Array, "filter with instance state (default: running)") {|v|
          opts[:state] = v
        }
        op.on('--monitoring one,two,three', Array, "filter with instance monitoring") {|v|
          opts[:monitoring] = v
        }
        op.on('--[no-]spot', "filter to spot or non-spot instances") {|v|
          opts[:spot] = v
        }
        Config.optional_options.each do |opt, tag|
          op.on("--#{opt.to_s.gsub('_', '-')} one,two,three", Array, opt) {|v|
            opts[opt.to_sym] = v
          }
        end
        op.on('-a', '--all', "list all hosts (remove default filter)") {|v|
          [:hostname, :role, :instance_id, :state, :monitoring].each do |key|
            opts.delete(key)
          end
          1.upto(Config.role_max_depth).each do |i|
            opts.delete("role#{i}".to_sym)
          end
          Config.optional_options.each do |opt, tag|
            opts.delete(opt.to_sym)
          end
        }
        op.on('--private-ip', '--ip', "show private ip address instead of hostname") {|v|
          opts[:private_ip] = v
        }
        op.on('--public-ip', "show public ip address instead of hostname") {|v|
          opts[:public_ip] = v
        }
        op.on('-i', '--info', "show host info") {|v|
          opts[:info] = v
        }
        op.on('-j', '--jsonl', "show host info in line delimited json") {|v|
          opts[:jsonl] = v
        }
        op.on('--json', "show host info in json") {|v|
          opts[:json] = v
        }
        op.on('--pretty-json', "show host info in pretty json") {|v|
          opts[:pretty_json] = v
        }
        op.on('--debug', "debug mode") {|v|
          opts[:debug] = v
        }
        op.on('-h', '--help', "show help") {|v|
          opts[:help] = v
        }
        op.on('-v', '--version', "show version") {|v|
          puts EC2::Host::VERSION
          exit 0
        }

        begin
          args = op.parse(argv)
        rescue OptionParser::InvalidOption => e
          usage e.message
        end

        if opts[:help]
          usage
        end

        opts
      end

      def run
        hosts = EC2::Host.new(condition).sort_by {|host| host.hostname }
        if options[:info]
          hosts.each do |host|
            $stdout.puts host.info
          end
        elsif options[:jsonl]
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
        _condition = HashUtil.except(options, :info, :jsonl, :json, :pretty_json, :debug, :private_ip, :public_ip)
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
