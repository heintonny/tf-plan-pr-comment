resource "azurerm_route_table" "example" {
  name                = "example-route-table"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
