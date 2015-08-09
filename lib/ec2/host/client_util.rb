require 'net/http'
require 'aws-sdk'

class EC2
  class Host
    class ClientUtil
      def self.get_instances
        # I do not use describe_instances(filter:) because it does not support array tag ..
        return @instances if @instances
        Aws.config.update(region: Config.aws_region, credentials: Config.aws_credentials)
        ec2 = Aws::EC2::Client.new
        @instances = ec2.describe_instances.reservations.map(&:instances).flatten
      end

      def self.get_instance_id
        return @instance_id if @instance_id
        begin
          http_conn = Net::HTTP.new('169.254.169.254')
          http_conn.open_timeout = 5
          @instance_id = http_conn.start {|http| http.get('/latest/meta-data/instance-id').body }
        rescue Net::OpenTimeout
          raise "HTTP connection to 169.254.169.254 is timeout. Probably, not an EC2 instance?"
        end
      end
    end
  end
end
