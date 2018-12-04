require 'pp'
require 'aws-sdk-ec2'
require 'dotenv'
Dotenv.load

# Aws.config.update({
#     region: 'us-west-2',
#       credentials: Aws::Credentials.new('akid', 'secret'),
# })

ec2 = Aws::EC2::Client.new
pp instances = ec2.describe_instances.reservations.map(&:instances)

require 'pry'
binding.pry
