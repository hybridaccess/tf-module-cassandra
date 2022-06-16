data "azurerm_subscription" "current" {}

data "external" "cassandra" {
  program = ["bash", "${path.module}/scripts/cassandra_config.sh"]

  query = {
    cluster_name      = var.name
    resource_group    = var.azurerm_resource_group
    subscription_name = data.azurerm_subscription.current.display_name
    tenant_id         = data.azurerm_subscription.current.tenant_id
  }

  depends_on = [azurerm_cosmosdb_cassandra_datacenter.this]
}