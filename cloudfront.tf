resource "aws_cloudfront_vpc_origin" "cloudfront-alb" {
  vpc_origin_endpoint_config {
    name                   = "ha-webapp-vpc-origin"
    arn                    = aws_lb.ALB.arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "http-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "alb-distribution" {
  origin {
    domain_name = aws_lb.ALB.dns_name
    origin_id   = "alb-distribution-origin"

    vpc_origin_config {
      vpc_origin_id = aws_cloudfront_vpc_origin.cloudfront-alb.id

    }
  }

  enabled = true

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "alb-distribution-origin"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_disabled.id

  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}



