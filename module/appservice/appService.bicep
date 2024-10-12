@description('Location for App Service')
param location string
param tags object

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Name of the Web App')
param webAppName string

@description('SKU for the App Service Plan (e.g., P1v2 for PremiumV2)')
param skuName string = 'P1v2'

@description('Tier for the App Service Plan (e.g., PremiumV2)')
param skuTier string = 'PremiumV2'

@description('Number of instances for scaling the App Service Plan')
param capacity int = 1

@description('Optional app settings for the Web App')
param appSettings array = [
  {key : 'WEBSITE_NODE_DEFAULT_VERSION'
  appsettings: '~14'}
]

@description('Enable HTTPS-only traffic')
param httpsOnly bool = true

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
    capacity: capacity
  }
  properties: {
    reserved: false  // Set to true if running Linux
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        for key in appSettings: {
          name: key
          value: appSettings[key]
        }
      ]
    }
    httpsOnly: httpsOnly
  }
}

output webAppUrl string = webApp.properties.defaultHostName
