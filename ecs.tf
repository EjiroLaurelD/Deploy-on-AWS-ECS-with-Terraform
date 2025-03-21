resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "spendsmart-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "spendsmart-app" {
  cluster_name = aws_ecs_cluster.my_ecs_cluster

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_service" "my_ecs_service" {
  name                 = "spendsmart-service"
  cluster              = aws_ecs_cluster.my_ecs_cluster.id
  task_definition      = aws_ecs_task_definition.main_task_definition.arn
  desired_count        = 1
  force_new_deployment = true
  # deployment_minimum_healthy_percent = 50
  # deployment_maximum_percent         = 200
  #launch_type                        = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.ecs_services.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.python_backend_tg.arn
    container_name   = var.app_name
    container_port   = var.container_port_be
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }
  # depends_on = [aws_alb_listener.http]
}


resource "aws_ecs_task_definition" "main_task_definition" {
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name       = "spendsmart"
      image      = "905418454680.dkr.ecr.eu-west-2.amazonaws.com/my-ecr"
      entryPoint = []
      #cpu       = 256
      #memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.region
          awslogs-stream-prefix = "app-logstream"
          awslogs-group         = aws_cloudwatch_log_group.my_ecs_service_log_group.name
        }
      }
      portMappings = [
        {
          containerPort = 5000
          # hostPort      = 80
          # protocol = "tcp"
        }
      ]
    }
  ])
  family                   = "spendsmart"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
}

resource "aws_ecs_service" "spendsmart-service-fe" {
  name            = "spendsmart-service-fe"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.fe_task_definition.arn
  desired_count   = 1
  #launch_type                        = "FARGATE"
  #deployment_minimum_healthy_percent = 50
  #deployment_maximum_percent         = 200
  force_new_deployment = true
  scheduling_strategy  = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.ecs_services.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.my_ecs_target_group.id
    container_name   = var.app_name2
    container_port   = var.container_port_fe
  }

  #depends_on = [ aws_alb_listener.http ]
}


resource "aws_ecs_task_definition" "fe_task_definition" {
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name  = "spendsmart-fe"
      image = "905418454680.dkr.ecr.eu-west-2.amazonaws.com/spendsmart-fe"
      #cpu       = 256
      #memory    = 512
      essential  = true
      entryPoint = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.region
          awslogs-stream-prefix = "app-logstream"
          awslogs-group         = aws_cloudwatch_log_group.my_ecs_service_log_group.name
        }
      }
      portMappings = [
        {
          containerPort = 3000
          #  hostPort      = 80
          #  protocol = "tcp"
        }
      ]
    }
  ])
  family                   = "spendsmart-fe"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
}

