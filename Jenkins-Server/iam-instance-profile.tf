resource "aws_iam_instance_profile" "instance_profile" {
  name = "jenkins-Server-Instance-Profile"
  role = aws_iam_role.aws_iam_role.name 
}