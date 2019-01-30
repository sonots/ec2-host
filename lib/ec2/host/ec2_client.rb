require 'net/http'
require 'aws-sdk-ec2'
require 'aws-sdk-sts'

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
        else # use profile
          shared_credentials = Aws::SharedCredentials.new(
            profile_name: Config.aws_profile,
            path: Config.aws_credential_file
          )
          profile = Aws.shared_config.instance_variable_get(:@parsed_config)[Config.aws_profile]
          if profile['credential_source'] == 'Ec2InstanceMetadata'
            Aws::InstanceProfileCredentials.new
          elsif profile['role_arn']
            assume_role_credentials(shared_credentials, profile['role_arn'])
          else
            shared_credentials
          end
        end
      end

      def assume_role_credentials(shared_credentials, role_arn)
        Aws::AssumeRoleCredentials.new(
          client: Aws::STS::Client.new(region: Config.aws_region, credentials: shared_credentials),
          role_arn: role_arn,
          role_session_name: Config.aws_profile
        )
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
