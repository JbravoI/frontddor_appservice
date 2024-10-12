// Set the scope to the subscription
targetScope = 'subscription'
param tags object = {
  ModifiedBy: ''
  ModifiedDateTime: ''
}
param location string

//enable resouces to deploy
param resourceGroupName string
param Name string = 'test'


// ResourceGroup
module ResourceGroup 'module/resourceGroup/resourceGroup.bicep' = {
  name: 'virtualMachine'
  params: {
    resourceGroupName : '${Name}-rg'
    location: 'eastus'
    tags: tags
  }
}

// Data Platform
module subDataPlatform 'subPlatform.bicep' = {
  name: 'subdataplatform'
  params: {
    location: location
    tags: tags
    Name : Name
    resourceGroupName: resourceGroupName
  }
}
