# How to run test

NOTE: Currently, mock is not supported yet. So, you have to create your own AWS account, and instances.

Configure .env file as

```
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=
EC2_HOST_CONFIG_FILE=.env
OPTIONAL_ARRAY_TAGS=Tags
OPTIONAL_STRING_TAGS=Service,Status
```

EC2 instance tags must be configured as followings:

```json
[
  {
    Name: test
    Roles: admin:admin,test
    Service: test
    Status: reserve
    Tags: standby
  }
  {
    Name: isucon4
    Roles: isucon4:qual
    Service: isucon4
    Status: active
    Tags: master
  }
]
```
