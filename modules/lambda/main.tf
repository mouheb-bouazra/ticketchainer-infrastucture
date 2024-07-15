# --- modules/lambda/main.tf ---

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda/hello-world-lambda"
  output_path = "${path.module}/../../lambda_function_payload.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${path.module}/../../layers/function.zip"
  layer_name = "lambda_layer"

  compatible_runtimes = ["nodejs18.x"]
  source_code_hash    = data.archive_file.lambda.output_base64sha256
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
        Effect = "Allow",
        Sid    = "",
      },
    ],
  })
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "cloudwatch_policy"
  description = "Policy to allow Lambda function to write to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/customAuthValidator-terraform"
}

resource "aws_iam_policy" "network_interface_policy" {
  name        = "network_interface_policy"
  description = "Policy to allow Lambda function to create network interfaces and manage network resources"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect : "Allow",
        Action : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterfacePermission",
          "ec2:DescribeNetworkInterfacePermissions",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:DescribeNetworkInterfaceAttribute",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeRegions",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets"
        ],
        Resource : "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_network_interface" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.network_interface_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_ssm_readonly" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_lambda_function" "customAuthValidator" {
  filename      = "${path.module}/../../lambda_function_payload.zip"
  function_name = "customAuthValidator-terraform"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  layers        = [aws_lambda_layer_version.lambda_layer.arn]

  source_code_hash = data.archive_file.lambda.output_base64sha256

  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = var.vpc_security_group_ids
  }

  environment {
    variables = {
      REGION           = var.region
      JWT_PUBLIC_KEY   = var.jwt_public_key
      REDIS_URL        = var.redis_endpoint
      DESTINATION      = "${var.api_gateway_execution_arn}/*/GET/"
      ENABLED_FOR_ORGS = var.enabled_for_orgs
    }
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.customAuthValidator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*"
}
