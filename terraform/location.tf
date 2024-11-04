# Map resource
resource "aws_location_map" "robot_map" {
  configuration {
    style = "VectorEsriStreets"
  }
  map_name = "${var.project_name}-map"
}

# Place index for geocoding
resource "aws_location_place_index" "robot_places" {
  data_source = "Esri"
  index_name  = "${var.project_name}-places"
}

# Route calculator
resource "aws_location_route_calculator" "robot_routes" {
  calculator_name = "${var.project_name}-routes"
  data_source    = "Esri"
}

# Geofence collection for operational boundaries
resource "aws_location_geofence_collection" "operation_areas" {
  collection_name = "${var.project_name}-areas"
}