resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  tags = {
    Name = "Static Site Bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "static_site_website" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-ownership" {
  bucket = aws_s3_bucket.static_site.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-public-block" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static_site_policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "index.html"
  source       = "web/index.html"  
  content_type = "text/html"
}



# CloudFront Distribution
resource "aws_cloudfront_distribution" "static_site_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id   = "S3-static-site"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Static site with HTTPS"
  default_root_object = "index.html"

  # Default Cache Behavior
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    target_origin_id       = "S3-static-site"

    # Forwarded Values (cookies, headers, query string)
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
      headers = []
    }
  }

  # Viewer Certificate block: CloudFront default certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Price Class (optional, select based on your needs)
  price_class = "PriceClass_100"

  # Restrictions block (required, even if you're not applying any geo-restrictions)
  restrictions {
    geo_restriction {
      restriction_type = "none" # This means no geo-blocking
    }
  }
}



