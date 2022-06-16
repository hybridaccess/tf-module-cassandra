locals {
  cluster_properties = jsondecode(data.external.cassandra.result.properties)
  seed_node_ips      = local.cluster_properties.seedNodes[*].ipAddress
  gossipCertificates = local.cluster_properties.gossipCertificates[*].pem
}