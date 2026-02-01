# Add more user groups if required to grant admin access since this is sandbox account
data "aws_iam_group" "ce12" {
  group_name = "sctp-ce-12-learner"
}

data "aws_iam_group" "instructor" {
  group_name = "instructor"
}

data "aws_availability_zones" "available" {
  state = "available"
}
