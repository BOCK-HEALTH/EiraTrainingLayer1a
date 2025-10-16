resource "aws_s3_bucket_policy" "static_site_public" {
  bucket = aws_s3_bucket.static_site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.static_site.arn}/*"
        ]
      }
    ]
  })
}
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.bucket
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id
  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

data "template_file" "index_html" {
  template = file("${path.module}/index.html.tftpl")
  vars = {
    api_gateway_url = var.api_gateway_url
  }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_site.bucket
  key          = "index.html"
  content      = data.template_file.index_html.rendered
  content_type = "text/html"
}