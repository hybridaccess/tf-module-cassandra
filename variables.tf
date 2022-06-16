variable "env" {
  description = "Environment to deploy cassandra"
  type        = string
  default     = "sandbox"
}
variable "location" {
  description = "Azure region"
  type        = string
  default     = "North Europe"
}

variable "node_count" {
  description = "Cassandra datacenter number of nodes"
  type        = number
  default     = 3
}

variable "node_sku" {
  description = "Virtual Machine SKU used for data centers"
  type        = string
  default     = "Standard_DS14_v2"
}

variable "disk_count" {
  description = "Number of disk used for data centers"
  type        = number
  default     = 4
}

variable "azurerm_resource_group" {
  type        = string
  description = "Name of resource group to deploy cassandra"
}

variable "labels_context" {
  description = "null-label module context"
  type        = string
  default     = "e30=" # base64ecode(jsonencode({}))
}

variable "name" {
  type        = string
  description = "Name of the cassandra cluster.  Note: This should be the same name as the existing cluster if configuring hybrid cluster"
}

variable "cassandra_vnet_id" {
  type        = string
  description = "ID of vnet to host cassandra mi"
}

variable "cassandra_subnet_id" {
  type        = string
  description = "ID of subnet to dedicate to cassandra mi"
}

variable "availability_zones_enabled" {
  description = "Determines whether availability zones are enabled"
  type        = bool
  default     = false
}

variable "lb_frontend_ip" {
  description = "Static private IP address of load balancer frontend IP address"
  type        = string
}

variable "external_seed_nodes" {
  description = "List of IP address of seed nodes from existing cluster to be added to this cluster"
  type        = list(string)
  default     = []
}

variable "enable_hybrid_cluster" {
  description = "Determines whether the managed cluster will be updated with seed nodes IP addresses and gossip Certificates from the existing cluster"
  type        = bool
  default     = false
}