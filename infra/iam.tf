
data "aws_iam_instance_profile" "lab_profile" {
  name = "LabInstanceProfile"
}

# (Opcional) Si necesitas referenciar el rol directamente en algún lado
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}