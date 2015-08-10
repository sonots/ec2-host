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

* **HOSTNAME_TAG**: EC2 tag key used to express a hostname. The default is `Name`.
* **ROLES_TAG**: EC2 tag keys used to express roles. The default is `Roles`
  * You can assign multiple roles seperated by `ARRAY_TAG_DELIMITER` (default: `,`)
  * Also, you can express levels of roles delimited by `ROLE_TAG_DELIMITER` (default `:`)
  * Example: admin:ami, then `EC2::Host.new(role: 'admin:ami')` and also `EC2::Host.new(role1: 'admin')` returns this host
* **ROLE_TAG_DELIMITER**: A delimiter to express levels of roles. Default is `:`
* **OPTIONAL_STRING_TAGS**: You may add optional non-array tags. You can specify multiple tags like `Service,Status`. 
* **OPTIONAL_ARRAY_TAGS**: You may add optional array tags. Array tags allows multiple values delimited by `ARRAY_TAG_DELIMITER` (default: `,`)
* **ARRAY_TAG_DELIMITER**: A delimiter to express array. Default is `,`
* **LOG_LEVEL**: Log level such as `info`, `debug`, `error`. The default is `info`. 

See [sampel.conf](./sample.conf)

## Tag Example

* **Name**: hostname
* **Roles**: app:web,app:db
* **Service**: sugoi
* **Status**: setup

## CLI Usage

```
$ ec2-host --role1 admin
host1
ip-XXX-XXX-XXX-XXX # if Name tag is not assigned
```

See `ec2-host help get-hosts` for details:

```
Usage:
  ec2-host get-hosts

Options:
  -h, [--hostname=one two three]                 # name or private_dns_name
  --usage, [--role=one two three]                # role
  --r1, --usage1, --u1, [--role1=one two three]  # role1, the 1st part of role delimited by :
  --r2, --usage2, --u2, [--role2=one two three]  # role2, the 2nd part of role delimited by :
  --r3, --usage3, --u3, [--role3=one two three]  # role3, the 3rd part of role delimited by :
  --ip, [--private-ip], [--no-private-ip]        # show private ip address instead of hostname
              [--public-ip], [--no-public-ip]    # show public ip address instead of hostname
  -i, [--info], [--no-info]                      # show host info, not only hostname
              [--debug], [--no-debug]            # debug mode

Search EC2 hosts
```

## Library Usage

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

