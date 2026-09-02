
resource "aws_iam_role" "ssm_ec2" {
  name = "${var.project_name}_ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ssm_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${var.project_name}_ec2_ssm_instance_profile"
  role = aws_iam_role.ssm_ec2.name
}

resource "aws_iam_policy" "ssm_user" {
  name = "${var.project_name}_ssm_user_iam_policy"
  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "Describe"
        Effect = "Allow"

        Action = [
          "ssm:DescribeInstanceInformation",
          "ec2:DescribeInstances"
        ]

        Resource = "*"
      },

      {
        Sid    = "StartSession"
        Effect = "Allow"

        Action = [
          "ssm:StartSession"
        ]

        Resource = "arn:aws:ec2:${var.aws_region}:*:instance/*"

        Condition = {
          StringEquals = {
            "ssm:resourceTag/SSMAccess" = "true"
          }
        }
      },

      {
        Sid    = "TerminateOwnSession"
        Effect = "Allow"

        Action = [
          "ssm:TerminateSession"
        ]

        Resource = "arn:aws:ssm:${var.aws_region}:*:session/$${aws:userid}-*"
      },

      {
        Sid    = "ResumeOwnSession"
        Effect = "Allow"

        Action = [
          "ssm:ResumeSession"
        ]

        Resource = "arn:aws:ssm:${var.aws_region}:*:session/$${aws:userid}-*"
      }
    ]
  })

}
