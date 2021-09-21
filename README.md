## Usage

Create a wildcard in ACM for the domain that we own
```hcl
data "aws_route53_zone" "externaldns_link" {
  name         = "${var.domain_name}."
}

module "acm_domain_wildcard" {
  source = "github.com/andymotta/acm-domain-wildcard"
  domain_name = var.domain_name
  zone_id = data.aws_route53_zone.externaldns_link.zone_id
}
```
If DNS is in a different AWS account:
```hcl
data "aws_route53_zone" "externaldns_link" {
  provider     = aws.dns
  name         = "${var.domain_name}."
}

provider "aws" {
  region = "us-west-2"
  profile = "default"
}

provider "aws" {
  alias = "dns"
  region = "us-west-2"
  profile = "awsacct2"
}

module "acm_domain_wildcard" {
  providers = {
    aws.dns = aws.dns
  }
  source = "github.com/andymotta/acm-domain-wildcard"
  domain_name = var.domain_name
  zone_id = data.aws_route53_zone.externaldns_link.zone_id
}
```

Then apply to Helm chart
```hcl
resource "helm_release" "chart" {
  name       = "release"
  repository = "repo"
  chart      = "chart"
  values = [
    templatefile("${path.module}/chart-values.yaml", {
      certificate_arn = var.certificate_arn
    })
  ]
}
```
```yaml
grafana:
  ingress:
    annotations:
      alb.ingress.kubernetes.io/certificate-arn: ${certificate_arn}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The name of a domain that you own | `string` | `""` | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Public zone for domain that will hold the domain verification records | `string` | `""` | yes |