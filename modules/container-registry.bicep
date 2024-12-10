@description('The name of the Azure Container Registry')
param name string

@description('The location for the Azure Container Registry')
param location string

@description('Enable admin user for the Azure Container Registry')
param acrAdminUserEnabled bool = true

@description('Key Vault resource ID for storing credentials')
param adminCredentialsKeyVaultResourceId string

@description('Key Vault secret name for username')
@secure()
param adminCredentialsKeyVaultSecretUserName string

@description('Key Vault secret name for password 1')
@secure()
param adminCredentialsKeyVaultSecretUserPassword1 string

@description('Key Vault secret name for password 2')
@secure()
param adminCredentialsKeyVaultSecretUserPassword2 string

resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

resource secretAdminPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword1
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

resource secretAdminPassword2 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword2
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}

output loginServer string = containerRegistry.properties.loginServer
