# IoT Thing and Certificate
resource "aws_iot_thing" "robot" {
  name = var.thing_name
}

resource "aws_iot_certificate" "cert" {
  active = true
}

# IoT Policies based on templates
resource "aws_iot_policy" "robot_policy" {
  name = "${var.project_name}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Publish",
          "iot:Receive",
          "iot:RetainPublish"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/odom",
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/cmd_vel",
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/fix",
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/rules/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Subscribe"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/gpsgo"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Connect"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:client/${var.thing_name}"
        ]
      }
    ]
  })
}

# Shadow Policy
resource "aws_iot_policy" "shadow_policy" {
  name = "${var.project_name}-shadow-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Subscribe"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/$aws/things/${var.thing_name}/shadow/name/${var.shadow_name}/update/documents"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Receive"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${var.thing_name}/shadow/name/${var.shadow_name}/update/documents"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Publish"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${var.thing_name}/shadow/name/${var.shadow_name}/update"
        ]
      }
    ]
  })
}

# Attach policies to certificate
resource "aws_iot_policy_attachment" "robot_policy_attachment" {
  policy = aws_iot_policy.robot_policy.name
  target = aws_iot_certificate.cert.arn
}

resource "aws_iot_policy_attachment" "shadow_policy_attachment" {
  policy = aws_iot_policy.shadow_policy.name
  target = aws_iot_certificate.cert.arn
}

# Attach certificate to thing
resource "aws_iot_thing_principal_attachment" "attachment" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.robot.name
}

# IoT Rule for Kinesis Data Stream
resource "aws_iot_topic_rule" "kinesis_rule" {
  name        = "${replace(var.project_name, "-", "_")}_to_kinesis"
  description = "Route ROS2 telemetry data to Kinesis Data Stream"
  enabled     = true
  sql         = "SELECT *, timestamp() as timestamp FROM '/odom', '/fix'"
  sql_version = "2016-03-23"

  kinesis {
    stream_name = aws_kinesis_stream.robot_telemetry.name
    role_arn    = aws_iam_role.iot_kinesis_role.arn
    partition_key = "$${timestamp()}"
  }
}

# Get the IoT endpoint
data "aws_iot_endpoint" "endpoint" {
  endpoint_type = "iot:Data-ATS"
}
