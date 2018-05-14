output "route53_production_zone_id" {
  value = "${aws_route53_zone.main.zone_id}"
}

output "route53_staging_zone_id" {
  value = "${aws_route53_zone.staging.zone_id}"
}
