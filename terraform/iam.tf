data "aws_caller_identity" "current" {}

resource "aws_iam_role" "iot_timestream_role" {
  name = "${var.project_name}-iot-timestream-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "iot_timestream_policy" {
  name = "${var.project_name}-iot-timestream-policy"
  role = aws_iam_role.iot_timestream_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "timestream:WriteRecords",
          "timestream:DescribeEndpoints"
        ]
        Resource = [
          aws_timestreamwrite_database.robot_telemetry.arn,
          "${aws_timestreamwrite_database.robot_telemetry.arn}/*"
        ]
      }
    ]
  })
}

# IAM role for IoT to Kinesis
resource "aws_iam_role" "iot_kinesis_role" {
  name = "${var.project_name}-iot-kinesis-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "iot_kinesis_policy" {
  name = "${var.project_name}-iot-kinesis-policy"
  role = aws_iam_role.iot_kinesis_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ]
        Resource = [aws_kinesis_stream.robot_telemetry.arn]
      }
    ]
  })
}

# Amplify IAM role
resource "aws_iam_role" "amplify_role" {
  name = "${var.project_name}-amplify-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
      }
    ]
  })
}

# Location Service policy
resource "aws_iam_role_policy" "amplify_location_policy" {
  name = "${var.project_name}-amplify-location-policy"
  role = aws_iam_role.amplify_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "geo:GetMap*",
          "geo:SearchPlaceIndex*",
          "geo:CalculateRoute*",
          "geo:GetGeofence*",
          "geo:ListGeofences"
        ]
        Resource = [
          "arn:aws:geo:${var.aws_region}:${data.aws_caller_identity.current.account_id}:map/${aws_location_map.robot_map.map_name}",
          "arn:aws:geo:${var.aws_region}:${data.aws_caller_identity.current.account_id}:place-index/${aws_location_place_index.robot_places.index_name}",
          "arn:aws:geo:${var.aws_region}:${data.aws_caller_identity.current.account_id}:route-calculator/${aws_location_route_calculator.robot_routes.calculator_name}",
          "arn:aws:geo:${var.aws_region}:${data.aws_caller_identity.current.account_id}:geofence-collection/${aws_location_geofence_collection.operation_areas.collection_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "timestream:Select",
          "timestream:DescribeTable",
          "timestream:ListMeasures"
        ]
        Resource = [
          aws_timestreamwrite_database.robot_telemetry.arn,
          "${aws_timestreamwrite_database.robot_telemetry.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iot:Publish"
        ]
        Resource = [
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/gpsgo"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_timestream_role" {
  name = "${var.project_name}-lambda-timestream-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_timestream_policy" {
  name = "${var.project_name}-lambda-timestream-policy"
  role = aws_iam_role.lambda_timestream_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "timestream:WriteRecords",
          "timestream:DescribeEndpoints"
        ]
        Resource = [
          aws_timestreamwrite_database.robot_telemetry.arn,
          "${aws_timestreamwrite_database.robot_telemetry.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream",
          "kinesis:ListShards"
        ]
        Resource = [aws_kinesis_stream.robot_telemetry.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}