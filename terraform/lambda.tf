resource "aws_lambda_function" "timestream_writer" {
  filename         = "lambda/timestream_writer.zip"
  function_name    = "${var.project_name}-timestream-writer"
  role            = aws_iam_role.lambda_timestream_role.arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 60

  environment {
    variables = {
      TIMESTREAM_DATABASE = aws_timestreamwrite_database.robot_telemetry.database_name
      TIMESTREAM_TABLE    = aws_timestreamwrite_table.robot_data.table_name
    }
  }
}

resource "aws_lambda_event_source_mapping" "kinesis_trigger" {
  event_source_arn  = aws_kinesis_stream.robot_telemetry.arn
  function_name     = aws_lambda_function.timestream_writer.arn
  starting_position = "LATEST"
  batch_size        = 100
}
