provider "aws" {
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2-host-web" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.nano"
  tags {
      Name = "ec2-host-web"
      Roles = "foo,web:test"
      Service = "ec2-host"
      Status = "reserve"
      Tags = "standby"
  }
}

resource "aws_instance" "ec2-host-db" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.nano"
  tags {
      Name = "ec2-host-db"
      Roles = "foo,db:test"
      Service = "ec2-host"
      Status = "active"
      Tags = "master"
  }
}
