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

      def ec2_instance?
        (not instance_id.nil?) rescue false
      end

      def raw_credentials
        if Config.aws_credential['credential_source'] == 'Ec2InstanceMetadata' || Config.aws_credential.empty?
          Aws::InstanceProfileCredentials.new
        elsif Config.aws_access_key_id and Config.aws_secret_access_key
          Aws::Credentials.new(Config.aws_access_key_id, Config.aws_secret_access_key)
        elsif File.readable?(Config.aws_credentials_file)
          Aws::SharedCredentials.new(profile_name: Config.aws_profile, path: Config.aws_credentials_file)
        elsif ec2_instance? # fallback to instance profile
          Aws::InstanceProfileCredentials.new
        end
      end

      def credentials
        if Config.aws_config['role_arn']
          # wrapped by assume role if necessary
          Aws::AssumeRoleCredentials.new(
            client: Aws::STS::Client.new(region: Config.aws_region, credentials: raw_credentials),
            role_arn: Config.aws_config['role_arn'],
            role_session_name: "ec2-host-session-#{Time.now.to_i}"
          )
        else
          raw_credentials
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
