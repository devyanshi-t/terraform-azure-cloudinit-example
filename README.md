# MODULE DEMO

NOT FOR PROD USE, ONLY FOR A TEST OF MODULES.

## Prerequisites

- Setup your **environment** using the following guide [Getting Started](https://github.com/Azure/caf-terraform-landingzones/blob/master/documentation/getting_started/getting_started.md) or you use it online with [GitHub Codespaces](https://github.com/features/codespaces).
- Access to an **Azure subscription**.

## Getting started

```terraform{
}
provider "azurerm" {
  features {}
}

module "cloudinit-example" {
    source = ".//terraform-azure-cloudinit-example"
    location = "enter value here "
  
}
output "pip" {
    value = module.cloudinit-example.public_ip
}

```
# terraform-azure-cloudinit-example
