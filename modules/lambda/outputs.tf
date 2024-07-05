# --- modules/lambda/outputs.tf ---

output "lambda_instance" {
  value = {
    arn              = aws_lambda_function.customAuthValidator.arn
    function_name    = aws_lambda_function.customAuthValidator.function_name
    invoke_arn       = aws_lambda_function.customAuthValidator.invoke_arn
    qualified_arn    = aws_lambda_function.customAuthValidator.qualified_arn
    role             = aws_lambda_function.customAuthValidator.role
    runtime          = aws_lambda_function.customAuthValidator.runtime
    source_code_hash = aws_lambda_function.customAuthValidator.source_code_hash
  }
}

