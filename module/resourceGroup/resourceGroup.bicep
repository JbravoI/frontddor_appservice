targetScope = 'subscription'

param resourceGroupName string
param location string
param tags object

// Resource Group for each Instance
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
  dependsOn: []
}
