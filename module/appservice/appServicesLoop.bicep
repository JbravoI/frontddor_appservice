// param location string

@description('Array of existing App Service names')
param appServiceNames array = [
  'test-21345wa'
]

// Loop through the array of existing App Services to reference their URLs
var appServiceResources = [for appServiceName in appServiceNames: {
  name: appServiceName

}]

// Declare existing App Services using array indexing
resource existingAppServiceResources 'Microsoft.Web/sites@2022-03-01' existing = [for i in range(0, length(appServiceNames)): {
  name: appServiceNames[i]
}]

// Output the URLs of the existing App Services
output appServiceUrls array = [for i in range(0, length(appServiceNames)): existingAppServiceResources[i].properties.defaultHostName]
output appServiceNamesNeeded array = [for i in range(0, length(appServiceNames)): existingAppServiceResources[i]]

