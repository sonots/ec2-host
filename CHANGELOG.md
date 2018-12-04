# 1.0.0 (2018/12/04)

Changes:

* Upgrade aws-sdk to v3, using aws-sdk-ec2.

# 0.6.0 (2017/05/20)

Fixes:

* Fix to support multile roles and roleNs with command line arguments as
  * ec2-host --role foo:a,bar:b
  * ec2-host --role1 foo,bar --role2 a,b

# 0.5.9 (2017/04/24)

Fixes:

* Fix display_short_info conditions (thanks to Spring_MT)

# 0.5.8 (2017/03/29)

Changes:

* Avoid no config file error (thanks to bob1983)

# 0.5.7 (2017/01/30)

Enhancements:

* Enhance cli help message

# 0.5.6 (2017/01/20)

Enhancements:

* Add --version option

# 0.5.5 (2017/01/20)

Enhancements:

* cil: sort_by hostname

# 0.5.4 (2017/01/19)

Enhancements:

* Add --spot and --no-spot option

Fixes:

* Show instances whose roles are empty

# 0.5.3 (2017/01/19)

Enhancements:

* Add `availability_zone` and `spot?`

# 0.5.2 (2016/12/08)

Changes:

* gem.add_runtime_dependency 'aws-sdk', "< 3.0.0"

# 0.5.1 (2016/12/02)

Fixes:

* Fix role matching for when --role1 was not specified

# 0.5.0 (2016/12/01)

Enhancements:

* Support role levels more than 3 by ROLE_MAX_DEPTH configuration

# 0.4.2 (2016/11/28)

Enhancements:

* Support /etc/default/ec2-host as default

# 0.4.1 (2016/11/24)

Enhancements:

* Get AWS_REGION from ~/.aws/config as default
* Fix default of AWS_PROFILE was set to 'nil' rather than nil

# 0.4.0 (2016/11/24)

Enhancements:

* Refactoring
* Add instance_type to to_hash (or -j option)
* Support new standard environment variables of AWS CLI such as AWS_DEFAULT_REGION, AWS_DEFAULT_PROFILE, AWS_CREDENTIAL_FILE.

# 0.3.1 (2016/04/21)

Enhancements:

* Add --all option

# 0.3.0 (2016/04/21)

Changes:

* List only running hosts as default via CLI

# 0.2.4 (2015/09/18)

Changes:

* Change --line-delimited-json option to --jsonl. See http://jsonlines.org/

# 0.2.3 (2015/08/28)

Changes:

* Remove shutting-down hosts from lists in addition to terminated as default

# 0.2.2 (2015/08/28)

yanked

# 0.2.1 (2015/08/26)

Fixes:

* Fix to be able to use together with capistrano 3

# 0.2.0 (2015/08/19)

Changes:

* Use optparse instead of thor
  * Format to specify array option arguments are changed from --option a b c to --option a,b,c
  * --long_option (underscore) is no longer available, only --long-option (dash) is available

# 0.1.1 (2015/08/11)

Changes:

* Rename `--json` to `--line-delimited-json`. Alias is kept as `-j`.
* Add `--json` which returns an arrayed json
* Add `--pretty-json` which returns json in pretty print

Fixes:

* Stop using Aws.config.update, it changes the default config

# 0.1.0 (2015/08/11)

Enhancements:

* Alias `--json` to `-j` option
* Possible speed up for instance_id, role, role1, role2, role3 condition

# 0.0.9 (2015/08/10)

Enhancements:

* Add `--state` and `--monitoring` option
* Remove terminated instances from list as default
* Support nested key such as instance.instance_id (as library)

# 0.0.8 (2015/08/10)

Enhancements:

* Add `--instance-id` option for filtering by instance_id

# 0.0.7 (2015/08/10)

Enhancements:

* Add `--json` option

# 0.0.6 (2015/08/10)

Enhancements:

* Add `--private-ip` (alias to `--ip`) and `--public-ip` options

# 0.0.5 (2015/08/10)

Changes:

* Change the display of --info option

# 0.0.4 (2015/08/10)

Enhancement:

* Add -r (and -u) option as a short option of --role (and --usage)

# 0.0.3 (2015/08/10)

Enhancement:

* Add ROLE_TAG_DELIMITER and ARRAY_TAG_DELIMITER config

# 0.0.2 (2015/08/10)

Fixes:

* Remove `require bundler/setup` not to require bundler

# 0.0.1 (2015/08/10)

first version
