require 'ec2-host'
require 'pp'

EC2::Host.new(role1: 'admin').each do |host|
  pp host
end
