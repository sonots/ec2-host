require 'net/http'
require 'aws-sdk'

class EC2
  class Host
    class ClientUtil
      def self.ec2(reload = false)
        if @ec2.nil? || reload
          @ec2 = Aws::EC2::Client.new(region: Config.aws_region, credentials: Config.aws_credentials)
        end
        @ec2
      end

      def self.instances(condition)
        describe_instances =
          if instance_id = condition[:instance_id]
            ec2.describe_instances(instance_ids: Array(instance_id))
          elsif role = (condition[:role] || condition[:usage]) and role.size == 1
            ec2.describe_instances(filters: [{name: "tag:#{Config.roles_tag}", values: ["*#{role.first}*"]}])
          elsif role1 = (condition[:role1] || condition[:usage1]) and role1.size == 1
            ec2.describe_instances(filters: [{name: "tag:#{Config.roles_tag}", values: ["*#{role1.first}*"]}])
          elsif role2 = (condition[:role2] || condition[:usage2]) and role2.size == 1
            ec2.describe_instances(filters: [{name: "tag:#{Config.roles_tag}", values: ["*#{role2.first}*"]}])
          elsif role3 = (condition[:role3] || condition[:usage3]) and role3.size == 1
            ec2.describe_instances(filters: [{name: "tag:#{Config.roles_tag}", values: ["*#{role3.first}*"]}])
          else
            ec2.describe_instances
          end
        describe_instances.reservations.map(&:instances).flatten
      end

      def self.instance_id
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
