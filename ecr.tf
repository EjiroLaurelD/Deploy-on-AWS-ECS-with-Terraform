resource "aws_ecr_repository" "my_ecr_repository" {
  name                 = "my-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {

    scan_on_push = true
  }
}

resource "aws_ecr_repository" "fe_ecr_repository" {
  name                 = "spendsmart-fe"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {

    scan_on_push = true
  }
}
