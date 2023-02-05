resource "aws_lambda_function" "error_lambda" {
    function_name = "mistaker-test"
    role = aws_iam_role.lambda_role.arn
    handler = "mistaker.lambda_handler"
    runtime = "python3.9"
    filename = "function.zip"
    source_code_hash = filebase64sha256("function.zip")
}

resource "aws_cloudwatch_event_rule" "scheduler" {
    name_prefix = "mistaker-scheduler-"
    schedule_expression = "rate(1 minute)"
}

resource "aws_lambda_permission" "allow_scheduler" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.error_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.scheduler.arn
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.scheduler.name
  arn       = aws_lambda_function.error_lambda.arn
}
