data "aws_iam_policy_document" "deploy_role_assume_policy" {
    statement {
      actions = [ "sts:AssumeRole" ]
      effect = "Allow"
      principals {
        type = "AWS"
        identifiers = [ "arn:aws:iam::${var.shared_account_id}:root" ]
      }
      condition {
        test = "ArnEquals"
        variable = "aws:PrincipalArn"
        values = [ "arn:aws:iam::${var.shared_account_id}:role/codebuild-terragrunt" ]
      }
    }
}

data "aws_iam_policy_document" "deploy_role_permissions" {
  statement {
    sid = "TerraformDeployPermissions"
    effect = "Allow"
    actions = "*"
    resources = "*"
  }
}

resource "aws_iam_role" "this" {
  name = var.deploy_role
  path = "/bootstrap"
  description = "IAM role that the Pipeline in the shared account will assume to deploy infrastructure"
  assume_role_policy = data.aws_iam_policy_document.deploy_role_assume_policy.json
}

resource "aws_iam_policy" "this" {
  name = "${var.deploy_role}Permissions"
  path = var.roles_path
  description = "IAM policy that grants permissions to the ${var.deploy_role} role"
  policy = data.aws_iam_policy_document.deploy_role_permissions.json
}

resource "aws_iam_policy_attachment" "this" {
  name = "The permissions policy ${aws_iam_policy.this.name} is attached to the role ${aws_iam_role.this.name}"
  policy_arn = aws_iam_policy.this.arn
  roles = [ aws_iam_role.this.arn ]
}