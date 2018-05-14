resource "aws_route53_zone" "main" {
  name = "rackbeat.com"

  tags {
    Environment = "production"
  }
}

resource "aws_route53_zone" "staging" {
  name = "rackbeat-staging.com"

  tags {
    Environment = "dev"
  }
}

resource "aws_route53_record" "app" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "app.rackbeat.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.lb.public_ip}"]
}
