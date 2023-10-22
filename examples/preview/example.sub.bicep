import { NamingOutput } from '../../dist/naming.module.preview.bicep'

targetScope = 'subscription'

param location string
param applicationName string
param environment string
param tags object = {}

var defaultTags = union({
  applicationName: applicationName
  environment: environment
}, tags)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${applicationName}-${environment}'
  location: location
  tags: defaultTags
}

module naming '../../dist/naming.module.preview.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'NamingDeployment'  
  params: {
    location: location
    suffix: [
      applicationName
      environment
    ]
    uniqueLength: 6
    uniqueSeed: rg.id
  }
}

module main 'example.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'MainDeployment'
  params: {
    location: location
    naming: naming.outputs.names
  }
}

output naming NamingOutput = naming.outputs.names
output appServiceName string = main.outputs.appServiceName
output appServicePlanName string = main.outputs.appServicePlanName
output storageAccountName string = main.outputs.storageAccountName