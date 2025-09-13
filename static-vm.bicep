// Deploy a basic Windows VM with static values

param location string = 'uaenorth'
param vmName string = 'testvm001'

// NIC and Network settings
param vnetName string = 'vmnet001'
param vnetAddressPrefix string = '10.40.0.0/16'
param subnetName string = 'vmsubnet'
param subnetPrefix string = '10.40.1.0/24'

param adminUsername string = 'azureUser'

@secure()
param adminPassword string

// Define subnetId variable using resourceId
var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnetName)

// Use subnetId in NIC definition
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  ...
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// Create the VM
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
