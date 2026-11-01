resource "aws_waf_web_acl" "this" {
  
}


resource "aws_cloudfront_origin_access_control" "this" { #Access to s3, lambda
  name = "my-oac"
  description = "Access to s3"
  origin_access_control_origin_type = "s3" #also: lambda, mediastore, mediapackagev2
  signing_behavior = "always" #or: never, no-overwrite
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_vpc_origin" "api" {
  vpc_origin_endpoint_config {
    name = "api-alb"
    arn = var.alb_arn
    http_port = 80
    https_port = 443
    origin_protocol_policy = "http-only"
    origin_ssl_protocols {
      items = [ "TLSV1.2" ]
      quantity = 1
    }
  }
}

#resource "aws_cloudfront_cache_policy" "this" {}
data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}
data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}
data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
}



resource "aws_cloudfront_distribution" "this" {
  aliases = var.domain_name
  enabled = true
  default_root_object = "index.html"

  # --------------------------------------- ORIGINS ---------------------------------------
  origin {
    origin_id = "api-origin"
    domain_name = var.alb_dns_name
    vpc_origin_config {
      vpc_origin_id = aws_cloudfront_vpc_origin.api.id
    }
  }
  origin {
    origin_id = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    domain_name = var.bucket_domain_name
  }


  # --------------------------------------- BEHAVIOR + CACHE ---------------------------------------
  #Static site: long caching, read only
  default_cache_behavior {
    target_origin_id = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = [ "GET", "HEAD" ]
    cached_methods = [ "GET", "HEAD" ]
    cache_policy_id = data.aws_cloudfront_cache_policy.optimized.id
    compress = true
  }

  ordered_cache_behavior {
    path_pattern = "/api/*"
    target_origin_id = "api-origin"
    viewer_protocol_policy = "https-only"
    allowed_methods = [ "GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE" ]
    cached_methods = [ "GET", "HEAD" ]
    cache_policy_id = data.aws_cloudfront_cache_policy.disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
  }
  # ordered_cache_behavior { path_pattern = "/api/billing*" ... } 

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSV1.2_2025"
  }
  # --------------------------------------- ERROR PAGES ---------------------------------------
  custom_error_response {
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
    error_caching_min_ttl = 10
  }
  custom_error_response {
    error_code = 500
    response_code = 500
    response_page_path = "/500.html"
    error_caching_min_ttl = 5
  }
  custom_error_response {
    error_code = 504
    response_code = 504
    response_page_path = "/504.html" # Static maintenance page in S3
    error_caching_min_ttl = 5
  }
}