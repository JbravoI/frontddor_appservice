@description('Location for Front Door')
param location string = resourceGroup().location

@description('Name of the Front Door instance')
param frontDoorName string
param tags object
//param customDomain string = '${frontDoorName}.azurefd.net'
param appServiceUrl string

@description('The SKU for the Front Door instance (Premium_AzureFrontDoor is used here)')
var frontDoorSku = 'Premium_AzureFrontDoor'

resource frontDoor 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorName
  location: location
  sku: {
    name: frontDoorSku
  }
  tags: tags
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: 'endpoint-${frontDoorName}'
  parent: frontDoor  // Correctly set the parent as the Front Door profile
  location: location
  properties: {
    enabledState: 'Enabled'
   // hostName: customDomain
  }
}

resource frontDoorRoutingRule 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: 'route-${frontDoorName}'
  parent: frontDoorEndpoint  // Correctly set the parent as the Frontend endpoint
  properties: {
    originGroup: {
      id: 'originGroupResourceId'  // Replace with the actual resource ID of the backend pool
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    linkToDefaultDomain: false
    patternsToMatch: [
      '/*'
    ]
    ruleType: 'Forward'
  }
}

resource backendPool 'Microsoft.Cdn/profiles/afdOriginGroups@2021-06-01' = {
  name: 'backendPool-${frontDoorName}'
  parent: frontDoor
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 2
    }
    healthProbeSettings: {
      probeIntervalInSeconds: 120
      probePath: '/'
      probeProtocol: 'Https'
      probeRequestType: 'HEAD'
    }
    backends: [
      {
        address: appServiceUrl  // Link App Service hostname as the backend
        httpPort: 80
        httpsPort: 443
        enabledState: 'Enabled'
        priority: 1
        weight: 50
      }
    ]
  }
}
