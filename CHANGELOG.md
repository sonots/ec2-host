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
