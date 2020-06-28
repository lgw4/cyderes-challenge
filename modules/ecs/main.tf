data "aws_ecs_task_definition" "nginx" {
  task_definition = aws_ecs_task_definition.nginx.family
  depends_on      = [aws_ecs_task_definition.nginx]
}

resource "aws_iam_role" "ecs-instance-role" {
  name               = "ecs-instance-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs-instance-policy.json
}

data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  path = "/"
  role = aws_iam_role.ecs-instance-role.id
  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "aws_iam_role" "ecs-service-role" {
  name               = "ecs-service-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs-service-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
  role       = aws_iam_role.ecs-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_ecs_service" "nginx_service" {
  name                               = "nginx-service"
  iam_role                           = aws_iam_role.ecs-service-role.name
  cluster                            = aws_ecs_cluster.nginx_ecs_cluster.id
  task_definition                    = "${aws_ecs_task_definition.nginx.family}:${max("${aws_ecs_task_definition.nginx.revision}", "${data.aws_ecs_task_definition.nginx.revision}")}"
  desired_count                      = var.desired_capacity
  deployment_minimum_healthy_percent = "50"
  deployment_maximum_percent         = "100"
  lifecycle {
    ignore_changes = [task_definition]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.nginx_target_group.arn
    container_port   = 80
    container_name   = "nginx"
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family                = "nginx"
  container_definitions = <<DEFINITION
[
  {
    "name": "nginx",
    "image": "${var.nginx_image}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "nginx",
          "awslogs-region": var.region,
          "awslogs-stream-prefix": "ecs"
        }
    },
    "memory": 256,
    "cpu": 128
  }
]
DEFINITION
}

resource "aws_alb_target_group" "nginx_target_group" {
  name                 = "nginx-target-group"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc.vpc_id
  deregistration_delay = "10"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200,301,302"
    path                = "/"
    protocol            = "HTTP"
    timeout             = "5"
  }

  stickiness {
    type = "lb_cookie"
  }

  tags = {
    Name = "nginx-target-group"
  }
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.nginx_alb_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.nginx_target_group.arn
    type             = "forward"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_nginx" {
  autoscaling_group_name = "nginx-autoscaling-group"
  alb_target_group_arn   = aws_alb_target_group.nginx_target_group.arn
  depends_on             = [aws_autoscaling_group.nginx-autoscaling-group]
}
