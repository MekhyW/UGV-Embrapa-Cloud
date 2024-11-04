resource "aws_timestreamwrite_database" "robot_telemetry" {
  database_name = "${var.project_name}-telemetry"
}

resource "aws_timestreamwrite_table" "robot_data" {
  database_name = aws_timestreamwrite_database.robot_telemetry.database_name
  table_name    = "${var.project_name}-data"

  retention_properties {
    magnetic_store_retention_period_in_days = 30
    memory_store_retention_period_in_hours  = 24
  }
}