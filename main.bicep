@description('The location for all resources')
param location string = resourceGroup().location

@description('The name prefix for all resources')
param namePrefix string

var containerRegistryName = '${namePrefix}acr'
var keyVaultName = '${namePrefix}kv'
var acrUsernameSecret = 'acr-username'
var acrPassword1Secret = 'acr-password1'
var acrPassword2Secret = 'acr-password2'

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: keyVault.outputs.keyVaultId
    adminCredentialsKeyVaultSecretUserName: acrUsernameSecret
    adminCredentialsKeyVaultSecretUserPassword1: acrPassword1Secret
    adminCredentialsKeyVaultSecretUserPassword2: acrPassword2Secret
  }
  dependsOn: [
    keyVault
  ]
}

var appServicePlanName = '${namePrefix}-asp'
module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: appServicePlanName
    location: location
  }
}

resource existingKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

var webAppName = '${namePrefix}-app'
module webApp 'modules/app-service.bicep' = {
  name: 'webApp'
  params: {
    name: webAppName
    location: location
    appServicePlanName: appServicePlan.outputs.name
    containerRegistryName: containerRegistryName
    containerRegistryImageName: 'python-flask-app'
    containerRegistryImageVersion: 'latest'
    dockerRegistryServerUrl: 'https://${containerRegistry.outputs.loginServer}'
    dockerRegistryServerUserName: existingKeyVault.getSecret(acrUsernameSecret)
    dockerRegistryServerPassword: existingKeyVault.getSecret(acrPassword1Secret)
  }
  dependsOn: [
    containerRegistry
    appServicePlan
    keyVault
  ]
}

output webAppHostName string = webApp.outputs.defaultHostName
output acrLoginServer string = containerRegistry.outputs.loginServer
