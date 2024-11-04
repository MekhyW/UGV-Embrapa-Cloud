output "iot_endpoint" {
  value = data.aws_iot_endpoint.endpoint.endpoint_address
}

output "certificate_pem" {
  value     = aws_iot_certificate.cert.certificate_pem
  sensitive = true
}

output "private_key" {
  value     = aws_iot_certificate.cert.private_key
  sensitive = true
}

output "rosbag_bucket_name" {
  value = aws_s3_bucket.rosbag_storage.id
}

output "timestream_database_name" {
  value = aws_timestreamwrite_database.robot_telemetry.database_name
}

output "timestream_table_name" {
  value = aws_timestreamwrite_table.robot_data.table_name
}
