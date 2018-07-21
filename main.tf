resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-${var.project_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy-${var.project_name}"
  path        = "/"
  description = "Policy used in trust relationship with CodeBuild"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}/*",
        "arn:aws:s3:::${var.bucket_name}/cache/*"
      ],
      "Action": [
        "s3:PutObject"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:::log-group:/aws/codebuild/${var.project_name}",
        "arn:aws:logs:::log-group:/aws/codebuild/${var.project_name}:*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:GetRepositoryPolicy",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchDeleteImage",
        "ecr:SetRepositoryPolicy",
        "ecr:GetLifecyclePolicy",
        "ecr:PutLifecyclePolicy",
        "ecr:DeleteLifecyclePolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:StartLifecyclePolicyPreview"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment"
  policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
  roles      = ["${aws_iam_role.codebuild_role.id}"]
}

resource "aws_codebuild_project" "codebuild" {
  name          = "${var.project_name}"
  description   = "${var.description}"
  build_timeout = "${var.build_timeout}"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type     = "S3"
    location = "${var.bucket_name}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${var.image_name}"
    type         = "LINUX_CONTAINER"
  }

  source {
    type     = "${var.repo_type}"
    location = "${var.repo_url}"
    buildspec = "${var.buildspec}"
  }

  tags {
    "Team" = "${var.team}"
  }
}
