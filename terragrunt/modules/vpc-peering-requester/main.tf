resource "aws_vpc_peering_connection" "requester" {
  peer_vpc_id = var.peer_vpc_id
  vpc_id      = var.vpc_id
  peer_region = var.peer_region

  tags = {
    Name        = "${var.project_name}-${var.region}-to-${var.peer_region}-vpc-peering-requester"
    Side        = "Requester"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "vpc_peer_request_private" {
  route_table_id              = var.private_route_table_id
  destination_cidr_block = var.destination_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
}

resource "aws_route" "vpc_peer_request_public" {
  route_table_id              = var.public_route_table_id
  destination_cidr_block = var.destination_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
}