@description('The name of the Key Vault')
param name string

@description('The location for the Key Vault')
param location string

@description('Enable vault for deployment')
param enableVaultForDeployment bool = true

@description('Array of role assignments')
param roleAssignments array = [
  {
    principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
    roleDefinitionIdOrName: '4633458b-17de-408a-b874-0445c86b69e6'
    principalType: 'ServicePrincipal'
  }
]

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: enableVaultForDeployment
    tenantId: subscription().tenantId
    accessPolicies: []
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for assignment in roleAssignments: {
  name: guid(keyVault.id, assignment.principalId, assignment.roleDefinitionIdOrName)
  scope: keyVault
  properties: {
    principalId: assignment.principalId
    roleDefinitionId: contains(assignment.roleDefinitionIdOrName, '/') ? assignment.roleDefinitionIdOrName : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionIdOrName)
    principalType: assignment.principalType
  }
}]

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
