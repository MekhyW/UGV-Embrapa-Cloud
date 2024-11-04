# Amplify App
resource "aws_amplify_app" "robot_dashboard" {
  name         = "${var.project_name}-dashboard"
  repository   = var.repository_url
  access_token = var.github_access_token

  build_spec = jsonencode({
    version = 1
    applications = [{
      frontend = {
        phases = {
          preBuild = {
            commands = [
              "npm ci"
            ]
          }
          build = {
            commands = [
              "npm run build"
            ]
          }
        }
        artifacts = {
          baseDirectory = "build"
          files = [
            "**/*"
          ]
        }
      }
    }]
  })

  environment_variables = {
    AMPLIFY_LOCATION_SERVICE_REGION = var.aws_region
    AMPLIFY_MAP_NAME               = aws_location_map.robot_map.map_name
    AMPLIFY_PLACE_INDEX_NAME       = aws_location_place_index.robot_places.index_name
    AMPLIFY_ROUTE_CALCULATOR_NAME  = aws_location_route_calculator.robot_routes.calculator_name
  }
}