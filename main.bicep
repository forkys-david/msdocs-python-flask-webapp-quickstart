@description('The location for all resources')
param location string = resourceGroup().location

@description('The name prefix for all resources')
param namePrefix string

var containerRegistryName = '${namePrefix}acr'
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
  }
}

var appServicePlanName = '${namePrefix}-asp'
module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: appServicePlanName
    location: location
  }
}

var webAppName = '${namePrefix}-app'
module webApp 'modules/app-service.bicep' = {
  name: 'webApp'
  params: {
    name: webAppName
    location: location
    appServicePlanName: appServicePlan.outputs.name
    containerRegistryName: containerRegistryName
    containerRegistryImageName: 'your-image-name'
    containerRegistryImageVersion: 'latest'
  }
  dependsOn: [
    containerRegistry
    appServicePlan
  ]
}

output webAppHostName string = webApp.outputs.defaultHostName
output acrLoginServer string = containerRegistry.outputs.loginServer 
