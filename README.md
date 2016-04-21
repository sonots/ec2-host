# ec2-host

Search hosts on AWS EC2

## Installation

```
gem install ec2-host
```

## Configuration

You can write a configuration file located at `/etc/sysconfig/ec2-host` (You can configure this path by `EC2_HOST_CONFIG_FILE` environment variable), or as environment variables:

AWS SDK (CLI) parameters:

* **AWS_REGION**; AWS SDK (CLI) region such as `ap-northeast-1`, `us-east-1`. 
* **AWS_ACCESS_KEY_ID**: AWS SDK (CLI) crendentials. Default loads a credentials file
* **AWS_SECRET_ACCESS_KEY**: AWS SDK (CLI) credentials. Default load a credentials file
* **AWS_PROFILE**: The profile key of the AWS SDK (CLI) credentails file. Default is `default`
* **AWS_CREDENTIALS_FILE**: Path of the AWS SDK (CLI) credentails file. Default is `$HOME/.aws/credentials`. See [Configuring the AWS Command Line Interface](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-config-files) for details. 

ec2-host parameters:

* **HOSTNAME_TAG (optional)**: EC2 tag key used to express a hostname. The default is `Name`.
* **ROLES_TAG (optional)**: EC2 tag keys used to express roles. The default is `Roles`
  * You can assign multiple roles seperated by `ARRAY_TAG_DELIMITER` (default: `,`)
  * Also, you can express levels of roles delimited by `ROLE_TAG_DELIMITER` (default `:`)
  * Example: admin:ami, then `EC2::Host.new(role: 'admin:ami')` and also `EC2::Host.new(role1: 'admin')` returns this host
* **ROLE_TAG_DELIMITER (optional)**: A delimiter to express levels of roles. Default is `:`
* **OPTIONAL_STRING_TAGS (optional)**: You may add optional non-array tags. You can specify multiple tags like `Service,Status`. 
* **OPTIONAL_ARRAY_TAGS (optional)**: You may add optional array tags. Array tags allows multiple values delimited by `ARRAY_TAG_DELIMITER` (default: `,`)
* **ARRAY_TAG_DELIMITER (optional)**: A delimiter to express array. Default is `,`
* **LOG_LEVEL (optional)**: Log level such as `info`, `debug`, `error`. The default is `info`. 

See [sample.conf](./sample.conf)

## Tag Example

* **Name**: hostname
* **Roles**: app:web,app:db
* **Service**: sugoi
* **Status**: setup

## CLI Usage

### CLI Example

```
$ ec2-host -j
{"hostname":"test","roles":["admin:ami","test"],"region":"ap-northeast-1","instance_id":"i-85900780","private_ip_address":"172.31.23.50","public_ip_address":null,"launch_time":"2013-09-16 06:14:20 UTC","state":"running","monitoring":"disabled"}
{"hostname":"ip-172-31-6-194","roles":["isucon4:qual"],"region":"ap-northeast-1","instance_id":"i-f88cc8e1","private_ip_address":"172.31.6.194","public_ip_address":null,"launch_time":"2014-10-20 15:57:23 UTC","state":"running","monitoring":"disabled"}
```

```
$ ec2-host
test
ip-172-31-6-194 # if Name tag is not available
```

```
$ ec2-host --role1 admin
test
```

```
$ ec2-host --role admin:ami
test
```

```
$ ec2-host --pretty-json
[
  {
    "hostname": "test",
    "roles": [
      "admin:ami",
      "test"
    ],
    "region": "ap-northeast-1",
    "instance_id": "i-85900780",
    "private_ip_address": "172.31.23.50",
    "public_ip_address": null,
    "launch_time": "2013-09-16 06:14:20 UTC",
    "state": "running",
    "monitoring": "disabled"
  },
  {
    "hostname": "ip-172-31-6-194",
    "roles": [
      "isucon4:qual"
    ],
    "region": "ap-northeast-1",
    "instance_id": "i-f88cc8e1",
    "private_ip_address": "172.31.6.194",
    "public_ip_address": null,
    "launch_time": "2014-10-20 15:57:23 UTC",
    "state": "running",
    "monitoring": "disabled"
  }
]
```

### CLI Help

```
$ bin/ec2-host --help
Usage: ec2-host [options]
        --hostname one,two,three     name or private_dns_name
    -r, --role one,two,three         role
        --r1, --role1 one,two,three  role1, the 1st part of role delimited by :
        --r2, --role2 one,two,three  role2, the 2st part of role delimited by :
        --r3, --role3 one,two,three  role3, the 3st part of role delimited by :
        --instance-id one,two,three  instance_id
        --state one,two,three        filter with instance state (default: running)
        --monitoring one,two,three   filter with instance monitoring
    -a, --all                        list all hosts (remove default filter)
        --private-ip, --ip           show private ip address instead of hostname
        --public-ip                  show public ip address instead of hostname
    -i, --info                       show host info
    -j, --jsonl                      show host info in line delimited json
        --json                       show host info in json
        --pretty-json                show host info in pretty json
        --debug                      debug mode
    -h, --help                       show help
```

## Library Usage

### Library Example

```ruby
require 'ec2-host'

hosts = EC2::Host.new(role: 'admin:ami')
hosts.each do |host|
  puts host
end
```

### Library Reference

See http://sonots.github.io/ec2-host/doc/frames.html.

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## For Developers

### ToDo

* Support assume-roles
* Use mock/stub to run test (currently, directly accessing to EC2)
* Should cache a result of describe-instances in like 30 seconds?

### How to Run test

See [spec/README.md](spec/README.md)

### How to Release Gem

1. Update gem.version in the gemspec
2. Update CHANGELOG.md
3. git commit && git push
4. Run `bundle exec rake release`

### How to Update doc

1. Run `./doc.sh`
2. git commit && git push (to gh-pages branch)

### Licenses

See [LICENSE](LICENSE)

