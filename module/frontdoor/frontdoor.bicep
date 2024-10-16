@description('Location for Front Door')
param location string

@description('Name of the Front Door instance')
param frontDoorName string
param tags object
//param customDomain string = '${frontDoorName}.azurefd.net'
param appServiceUrls array
param frontDoorOriginName array
var frontDoorSku = 'Standard_AzureFrontDoor'

resource frontDoor 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorName
  location: 'global'
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
      id: frontDoorOriginGroup.id // Replace with the actual resource ID of the backend pool
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: 'backendPool-${frontDoorName}'
  parent: frontDoor
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 2
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probeIntervalInSeconds: 120
      probePath: '/'
      probeProtocol: 'Https'
      probeRequestType: 'HEAD'
    }
  }
}

// Loop through the array of App Service URLs to create Front Door Origins
resource frontDoorOrigins 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for i in range(0, length(appServiceUrls)): {
  name: 'origin-${i}'
  parent: frontDoorOriginGroup
  properties: {
    hostName: appServiceUrls[i]
    httpPort: 80
    httpsPort: 443
    originHostHeader: appServiceUrls[i]
    priority: 1 
    weight: 1000
    enforceCertificateNameCheck: true
    enabledState: 'Enabled'
  }
}]

// resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
//   name: frontDoorOriginName
//   parent: frontDoorOriginGroup
//   properties: {
//     hostName: appServiceUrl
//     httpPort: 80
//     httpsPort: 443
//     originHostHeader: appServiceUrl
//     priority: 1
//     weight: 1000
//     enforceCertificateNameCheck: true
//     enabledState: 'Enabled' 
//   }
// }


// Output the names of created Front Door Origins for confirmation
output frontDoorOriginNames array = [for i in range(0, length(appServiceUrls)): frontDoorOrigins[i].name]
