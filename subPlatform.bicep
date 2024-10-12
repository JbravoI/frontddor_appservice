targetScope = 'subscription'

param tags object
param location string
param resourceGroupName string
param Name string

// Appservice
module AppService 'module/appservice/appservice.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'appservice'
  params: {
    location : location
    webAppName : '${Name}-21345wa'
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
    frontDoorName : '${Name}-223fd'
    appServiceUrl : AppService.outputs.webAppUrl
    frontDoorOriginName : AppService.outputs.webAppNames
    tags: tags
  }
  dependsOn: [
    AppService
  ]
}

