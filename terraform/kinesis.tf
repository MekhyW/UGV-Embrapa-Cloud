resource "aws_kinesis_stream" "robot_telemetry" {
  name             = "${var.project_name}-telemetry-stream"
  shard_count      = 1
  retention_period = 24

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
