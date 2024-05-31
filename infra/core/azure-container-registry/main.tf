resource "azurerm_container_registry" "this" {
  name                          = replace("acr${var.application_code}${var.container_registry_name}", "-", "")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.acr_sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "georeplications" {
    for_each = { for idx, rep in var.georeplication_locations : idx => rep }
    content {
      location                = georeplication.value.location
      zone_redundancy_enabled = georeplication.value.zone_redundancy_enabled
    }
  }
  network_rule_set {
    default_action = "Deny"

    # dynamic "ip_rule" {
    #   for_each = var.permitted_cidr
    #   content {
    #     action   = "Allow"
    #     ip_range = ip_rule.value.address_prefix
    #   }
    # }
  }
}