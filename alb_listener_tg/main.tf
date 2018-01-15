resource "aws_alb_target_group" "target_group" {
  name      = "${var.name}"
  port      = "${var.port}"
  protocol  = "${var.protocol}"
  vpc_id    = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    timeout             = "${var.timeout}"
    interval            = "${var.interval}"
    unhealthy_threshold = "${var.unhealthy_threshold}"
    healthy_threshold   = "${var.healthy_threshold}"
    protocol            = "${var.protocol}"
    path                = "${var.health_check}"
    matcher             = "${var.matcher}"
  }

  stickiness {
   type = "${var.stickiness_type}"
   enabled = "${var.stickiness_enabled}"
   cookie_duration = "${var.stickiness_cookie}"
  }
}

resource "aws_alb_listener" "listener" {
   load_balancer_arn = "${var.alb_arn}"
   port = "${var.port}"
   protocol = "${var.protocol}"

   default_action {
     target_group_arn = "${aws_alb_target_group.target_group.arn}"
     type = "forward"
   }
}

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = "${var.alb_listener_id}"
  priority     = "${var.priority}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.target_group.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.domain}"]
  }
}
