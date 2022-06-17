locals {
  #cluster_properties = jsondecode(data.external.cassandra.result.properties)
  #seed_node_ips      = local.cluster_properties.seedNodes[*].ipAddress
  #gossipCertificates = local.cluster_properties.gossipCertificates[*].pem

  node_ips_file = "${path.module}/nodes_ips.txt"
  node_ips_data = jsondecode(data.local_file.node_ips.content)
  node_ips      = local.node_ips_data[*].ipAddress
}