require 'net/http'
require 'aws-sdk-ec2'

class EC2
  class Host
    class EC2Client
      def instances(condition)
        filters = build_filters(condition)
        instances =
          if filters
            ec2.describe_instances(filters: filters)
          elsif instance_id = condition[:instance_id]
            ec2.describe_instances(instance_ids: Array(instance_id))
          else
            ec2.describe_instances
          end
        instances.reservations.map(&:instances).flatten
      end

      def instance_id
        return @instance_id if @instance_id
        begin
          http_conn = Net::HTTP.new('169.254.169.254')
          http_conn.open_timeout = 5
          @instance_id = http_conn.start {|http| http.get('/latest/meta-data/instance-id').body }
        rescue Net::OpenTimeout
          raise "HTTP connection to 169.254.169.254 is timeout. Probably, not an EC2 instance?"
        end
      end

      private

      def ec2
        @ec2 ||= Aws::EC2::Client.new(region: Config.aws_region, credentials: credentials)
      end

      def credentials
        if Config.aws_access_key_id and Config.aws_secret_access_key
          Aws::Credentials.new(Config.aws_access_key_id, Config.aws_secret_access_key)
        else
          Aws::SharedCredentials.new(profile_name: Config.aws_profile, path: Config.aws_credential_file)
        end
      end

      def build_filters(condition)
        if role = (condition[:role] || condition[:usage]) and role.size == 1
          return [{name: "tag:#{Config.roles_tag}", values: ["*#{role.first}*"]}]
        end
        1.upto(Config.role_max_depth).each do |i|
          if role = (condition["role#{i}".to_sym] || condition["usage#{i}".to_sym]) and role.size == 1
            return [{name: "tag:#{Config.roles_tag}", values: ["*#{role.first}*"]}]
          end
        end
        nil
      end
    end
  end
end
