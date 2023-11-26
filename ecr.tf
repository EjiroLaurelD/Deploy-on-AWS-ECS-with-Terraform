resource "aws_ecr_repository" "my_ecr_repository" {
  name                 = "my-ecr"
  image_tag_mutability = "MUTABLE"
}

