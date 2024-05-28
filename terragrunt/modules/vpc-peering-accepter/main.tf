resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = var.peer_connection_id
  auto_accept               = true

  tags = {
    Name        = "${var.project_name}-${var.region}-from-${var.peer_region}-vpc-peering-accepter"
    Side        = "Accepter"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "vpc_peer_accepter_private" {
  route_table_id              = var.private_route_table_id
  destination_cidr_block = var.destination_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}

resource "aws_route" "vpc_peer_accepter_public" {
  route_table_id              = var.public_route_table_id
  destination_cidr_block = var.destination_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}