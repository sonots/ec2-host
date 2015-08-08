# ec2-host

Search hosts in EC2 instance from Roles tag

## Installation

```
gem install ec2-host
```

## Configuration

You can write a configuration file located at `/etc/sysconfig/ec2-host` (You can configure this path by `EC2_HOST_CONFIG_FILE` environment variable), or as environment variables:

* **AWS_ACCESS_KEY_ID**: AWS SDK (CLI) crendentials
* **AWS_SECRET_ACCESS_KEY**: AWS SDK (CLI) credentials
* **AWS_REGION**; AWS SDK (CLI) config. such as `ap-northeast-1`, `us-east-1`. 
* **HOSTNAME_TAG**: EC2 tag key used to express a hostname. The default is `Name`.
* **ROLES_TAG**: EC2 tag keys used to express roles. The default is `Roles`
  * You can assign multiple roles seperated by `,` comma
  * Also, you can express levels of roles delimited by `:`.
  * Example: admin:ami, then `EC2::Host.new(role: 'admin:ami')` and also `EC2::Host.new(role1: 'admin')` returns this host
* **OPTIONAL_ARRAY_TAGS**: You may add optional array tags delimited by `,` command.
* **OPTIONAL_STRING_TAGS**: You may add optional tags
* **LOG_LEVEL**: Log level such as `info`, `debug`, `error`. The default is `info`. 

See [sampel.conf](./sample.conf)

## CLI Usage

```
$ ec2-host --role1 admin
host1
host2
```

See `ec2-host -h` for details:

```
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
