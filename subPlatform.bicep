targetScope = 'subscription'

param tags object
param location string
param resourceGroupName string
param Name string

// Appservice
module AppService 'module/appservice/appservice.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'frontdoor'
  params: {
    location : location
    webAppName : '${Name}-wa'
    appServicePlanName : '${Name}-asp'
    tags: tags
  }
}

// frontdoor
module FrontDoor 'module/frontdoor/frontdoor.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'frontdoor'
  params: {
    location : location
    frontDoorName : '${Name}-fd'
    appServiceUrl : AppService.outputs.webAppUrl
    tags: tags
  }
  dependsOn: [
    AppService
  ]
}

