@description('The name of the App Service')
param name string

@description('The location for the App Service')
param location string

@description('The name of the App Service Plan')
param appServicePlanName string

@description('The name of the Container Registry')
param containerRegistryName string

@description('The name of the container image')
param containerRegistryImageName string

@description('The version/tag of the container image')
param containerRegistryImageVersion string

@description('Docker Registry Server URL')
@secure()
param dockerRegistryServerUrl string

@description('Docker Registry Server Username')
@secure()
param dockerRegistryServerUserName string

@description('Docker Registry Server Password')
@secure()
param dockerRegistryServerPassword string

var dockerAppSettings = {
  DOCKER_REGISTRY_SERVER_URL: dockerRegistryServerUrl
  DOCKER_REGISTRY_SERVER_USERNAME: dockerRegistryServerUserName
  DOCKER_REGISTRY_SERVER_PASSWORD: dockerRegistryServerPassword
  WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  kind: 'app'
  properties: {
    serverFarmId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
      appSettings: [for setting in items(dockerAppSettings): {
        name: setting.key
        value: setting.value
      }]
    }
  }
}

output id string = appService.id
output name string = appService.name
output defaultHostName string = appService.properties.defaultHostName
