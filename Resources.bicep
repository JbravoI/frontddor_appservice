// Set the scope to the subscription
targetScope = 'subscription' 
param tags object = {
  ModifiedBy: 'asdf'
  ModifiedDateTime: 'asbf'
}
param location string = 'eastus'

//enable resouces to deploy
param resourceGroupName string = '${Name}-rg'
param Name string = 'test'


// ResourceGroup
module ResourceGroup 'module/resourceGroup/resourceGroup.bicep' = {
  name: 'ResourceGroup'
  params: {
    resourceGroupName : resourceGroupName
    location: location
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
