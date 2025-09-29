resource "aws_vpc" "my_vpc" {
    cidr_block = var.cidr
}

resource "aws_subnet" "my_subnet1" {
    vpc_id     = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "my_subnet2" {
    vpc_id     = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
}

resource "aws_route_table_association" "rta1" {
    subnet_id      = aws_subnet.my_subnet1.id
    route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "rta2" {
    subnet_id      = aws_subnet.my_subnet2.id
    route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "websg" {
    name        = "web"
    vpc_id      = aws_vpc.my_vpc.id

    ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "Shivankkumar2025project" # Change to a globally unique name

  }
resource "aws_instance" "web_serer_1" {
    ami                    = "02d26659fd82cf299"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.websg.id]
    subnet_id              = aws_subnet.my_subnet1.id
    user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "web_server2" {
    ami                    = "02d26659fd82cf299"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.websg.id]
    subnet_id              = aws_subnet.my_subnet2.id
    user_data              = base64encode(file("userdata1.sh"))
  
}
#create lb
resource "aws_lb" "myalb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.websg.id]
  subnets            = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]

  enable_deletion_protection = false

  tags = {
    Name = "my-alb"
  }
}
resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "my-targets"
  }
  
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web_serer_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web_server2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
 default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
output "alb_dns_name" {
    value = aws_lb.myalb.dns_name
  }


