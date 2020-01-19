provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_ecs_cluster" "ECS_CLUSTER" {
  name = "${var.cluster-name}"
}

resource "aws_iam_role" "ecs-instance-role" {
  name = "ecs-instance-role"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
    role       = "${aws_iam_role.ecs-instance-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile"
    role = "${aws_iam_role.ecs-instance-role.name}"
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
    name                        = "ecs-launch-configuration"
    image_id                    = "${var.image_id}"
    instance_type               = "t2.micro"
    iam_instance_profile        = "${aws_iam_instance_profile.ecs-instance-profile.id}"

    lifecycle {
      create_before_destroy = true
    }

    associate_public_ip_address = "true"
    user_data                   = <<EOF
 #!/bin/bash
 echo ECS_CLUSTER=opstree >> /etc/ecs/ecs.config
 EOF
}
resource "aws_autoscaling_group" "ecs-autoscaling-group" {
    name                        = "ecs-autoscaling-group"
    max_size                    = "3"
    min_size                    = "1"
    desired_capacity            = "1"
    launch_configuration        = "${aws_launch_configuration.ecs-launch-configuration.name}"
    vpc_zone_identifier         = ["${var.subnet_1}" , "${var.subnet_2}"]
 }

