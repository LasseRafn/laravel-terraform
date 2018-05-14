######
# ELB
######
resource "aws_lb" "this" {
  name                = "${var.name}"
  load_balancer_type  = "${var.load_balancer_type}"
  subnets             = ["${var.subnets}"]
  internal            = "${var.internal}"
  security_groups     = ["${var.security_groups}"]

  enable_deletion_protection = true

  subnet_mapping {
    subnet_id    = "${var.public_subnet_id}"
    allocation_id = "${var.public_ips}"
  }

  cross_zone_load_balancing   = "${var.cross_zone_load_balancing}"
  idle_timeout                = "${var.idle_timeout}"
  connection_draining         = "${var.connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"

  listener     = ["${var.listener}"]
  access_logs  = ["${var.access_logs}"]
  health_check = ["${var.health_check}"]

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}
