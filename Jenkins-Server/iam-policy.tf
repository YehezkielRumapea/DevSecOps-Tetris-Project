resource "aws_iam_role_policy_attachment" "iam-policy" {
  role      = aws_iam_role.aws_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}