resource "random_password" "this" {
  length  = 16
  special = false
}

resource "azurerm_cosmosdb_cassandra_cluster" "this" {
  name                           = var.name
  resource_group_name            = var.azurerm_resource_group
  location                       = var.location
  delegated_management_subnet_id = var.cassandra_subnet_id
  default_admin_password         = random_password.this.result

  timeouts {
    create = "60m"
    delete = "60m"
  }

  depends_on = [azurerm_role_assignment.this, azurerm_role_assignment.this2]
}

resource "azurerm_cosmosdb_cassandra_datacenter" "this" {
  name                           = "${var.name}-dc"
  location                       = var.location
  cassandra_cluster_id           = azurerm_cosmosdb_cassandra_cluster.this.id
  delegated_management_subnet_id = var.cassandra_subnet_id
  node_count                     = var.node_count
  disk_count                     = var.disk_count
  sku_name                       = var.node_sku
  availability_zones_enabled     = var.availability_zones_enabled

  timeouts {
    create = "60m"
    delete = "60m"
  }
}

// Update cluster with optional external seed nodes

resource "null_resource" "external_nodes" {
  for_each = var.enable_hybrid_cluster ? tomap({ enabled = true }) : {}

  provisioner "local-exec" {
    command = "az managed-cassandra cluster update --cluster-name ${var.name} --resource-group ${var.azurerm_resource_group} --external-seed-nodes ${join(" ", var.external_seed_nodes)} --subscription \"${data.azurerm_subscription.current.display_name}\""
  }

  triggers = {
    seed = join(",", var.external_seed_nodes)
  }

  depends_on = [azurerm_cosmosdb_cassandra_datacenter.this]
}

// Get nodes ip addresses from cluster

resource "null_resource" "get_nodes_ips" {

  provisioner "local-exec" {
    command = "az managed-cassandra cluster show --cluster-name ${var.name} --resource-group ${var.azurerm_resource_group} --subscription \"${data.azurerm_subscription.current.display_name}\" --query \"properties.seedNodes\" -o json > ${local.node_ips_file} "
  }

  triggers = {
    nodes = var.node_count
  }

  depends_on = [azurerm_cosmosdb_cassandra_datacenter.this]
}



// Cassandra nodes load balancer

resource "azurerm_lb" "this" {
  name                = "${var.name}-lb"
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                          = "PrivateIPAddress"
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = var.lb_frontend_ip
    subnet_id                     = var.cassandra_subnet_id
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "${var.name}-nodes"
}

resource "azurerm_lb_backend_address_pool_address" "this" {
  count = var.node_count

  name                    = "node-${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
  virtual_network_id      = var.cassandra_vnet_id
  ip_address              = local.node_ips[count.index]

  depends_on = [data.local_file.node_ips]
}

resource "azurerm_lb_rule" "this" {
  name                           = "cassandra"
  loadbalancer_id                = azurerm_lb.this.id
  frontend_ip_configuration_name = azurerm_lb.this.frontend_ip_configuration[0].name
  protocol                       = "Tcp"
  frontend_port                  = 9042
  backend_port                   = 9042
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this.id]
}

resource "azurerm_lb_probe" "this" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "cassandra"
  port            = 9042
}
