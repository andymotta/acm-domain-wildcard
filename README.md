## Usage

Create a wildcard in ACM for the domain that we own in the route53 account for ghost ingress
```hcl
data "aws_route53_zone" "externaldns_link" {
  provider     = aws.dns
  name         = "${var.domain_name}."
}

module "acm_domain_wildcard" {
  source = "./modules/acm-domain-wildcard"
  domain_name = var.domain_name
  zone_id = data.aws_route53_zone.externaldns_link.zone_id
}
```
Then apply to Helm chart
```hcl
resource "helm_release" "ghost" {
  name       = "ghost"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "ghost"
  values = [
    templatefile("ghost-values.yaml", {
      certificate_arn = module.acm_domain_wildcard.certificate_arn
    })
  ]
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The name of a domain that you own | `string` | `""` | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Public zone for domain that will hold the domain verification records | `string` | `""` | yes |