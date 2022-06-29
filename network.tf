resource "azurerm_role_assignment" "this" {
  scope                = var.cassandra_vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = "7711f534-a5ca-4cef-9c6c-8c389b135048"
}

resource "azurerm_role_assignment" "this2" {
  scope                = var.cassandra_vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = "a232010e-820c-4083-83bb-3ace5fc29d0b"
}
