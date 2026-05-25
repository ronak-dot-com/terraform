data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
}

locals {
  nginx_userdata = <<-EOF
    #!/bin/bash
    # Update system
    yum update -y

    # Install nginx
    yum install -y nginx

    # Create a custom index page showing hostname
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

    cat > /usr/share/nginx/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>AWS Practice - Nginx Server</title>
      <style>
        body { font-family: Arial, sans-serif; background: #f0f4f8; display: flex;
               justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: white; border-radius: 12px; padding: 40px; box-shadow: 0 4px 20px rgba(0,0,0,0.1);
                max-width: 500px; text-align: center; }
        h1 { color: #232f3e; }
        .badge { background: #ff9900; color: white; padding: 6px 14px;
                 border-radius: 20px; font-weight: bold; display: inline-block; margin: 8px 0; }
        .info { color: #555; margin: 8px 0; font-size: 0.95em; }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>&#9989; Nginx Running!</h1>
        <p class="info">Served by AWS EC2 via Application Load Balancer</p>
        <div class="badge">Instance: $INSTANCE_ID</div><br>
        <div class="badge">AZ: $AZ</div><br>
        <div class="badge">Private IP: $PRIVATE_IP</div>
        <p class="info" style="margin-top:20px">Refresh to see load balancing in action!</p>
      </div>
    </body>
    </html>
    HTML

    # Enable and start nginx
    systemctl enable nginx
    systemctl start nginx
  EOF
}

resource "aws_instance" "nginx" {
  count = 2

  ami                    = local.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.key_name

  user_data = local.nginx_userdata

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional" 
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-nginx-${count.index + 1}"
    Role = "WebServer"
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = false 
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-tg"
  }
}

resource "aws_lb_target_group_attachment" "nginx" {
  count            = length(aws_instance.nginx)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.nginx[count.index].id
  port             = 80
}

resource "aws_lb" "this" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection       = false 
  enable_cross_zone_load_balancing = true
  drop_invalid_header_fields       = true

  access_logs {
    bucket  = ""
    enabled = false  
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
