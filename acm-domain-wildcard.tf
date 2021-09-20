resource "aws_acm_certificate" "externaldns_link" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "externaldns_link" {
  certificate_arn         = aws_acm_certificate.externaldns_link.arn
  validation_record_fqdns = [for record in aws_route53_record.externaldns_link : record.fqdn]
}

resource "aws_route53_record" "externaldns_link" {
  provider = aws.dns
  for_each = {
    for dvo in aws_acm_certificate.externaldns_link.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.externaldns_link.certificate_arn
}