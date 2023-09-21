# Terraform Test

## Introduction

This README provides instructions on how to use Terraform to deploy infrastructure on Microsoft Azure. Terraform is an Infrastructure as Code (IaC) tool that allows you to define and provision your infrastructure using declarative configuration files.

In this guide, you will learn how to set up Terraform, configure Azure authentication, create a simple Azure resource, and deploy it using Terraform.

## Prerequisites

Before you begin, make sure you have the following prerequisites in place:

1. **Terraform**: Install Terraform on your local machine by following the instructions provided at [Terraform Downloads](https://www.terraform.io/downloads.html).

2. **Azure Subscription**: You will need an active Azure subscription. If you don't have one, you can sign up for a free trial at [Azure Free Account](https://azure.com/free).

3. **Azure CLI**: Install the Azure Command-Line Interface (CLI) from [Azure CLI Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

4. **Azure Service Principal**: Create an Azure Service Principal to authenticate Terraform to Azure. You can do this using the Azure CLI or Azure Portal. Make sure to note down the following details:
   - **Client ID**
   - **Client Secret**
   - **Subscription ID**
   - **Tenant ID**

## Configuration

1. **Azure Authentication**: Set up Azure authentication using your Azure Service Principal credentials. You can configure it by setting the following environment variables or using a `provider` block in your Terraform configuration files:

   ```bash
   export ARM_CLIENT_ID="YOUR_CLIENT_ID"
   export ARM_CLIENT_SECRET="YOUR_CLIENT_SECRET"
   export ARM_SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
   export ARM_TENANT_ID="YOUR_TENANT_ID"
   ```

   Alternatively, you can use a `provider` block in your Terraform configuration file (`main.tf`):

   ```hcl
   provider "azurerm" {
     features {}
   }
   ```

   Terraform will use the environment variables or the provider block to authenticate with Azure.

2. **Terraform Configuration**: Create a Terraform configuration file (e.g., `main.tf`) to define your infrastructure resources. Here is an example that creates a simple Azure resource group:

   ```hcl
   provider "azurerm" {
     features {}
   }

   resource "azurerm_resource_group" "example" {
     name     = "example-resources"
     location = "East US"
   }
   ```

3. **Initialize Terraform**: Run the following command in the directory containing your Terraform configuration file to initialize your working directory:

   ```bash
   terraform init
   ```

4. **Deploy Infrastructure**: After initializing, apply your Terraform configuration to create the Azure resources:

   ```bash
   terraform apply
   ```

   Confirm the action by typing "yes" when prompted.

## Cleaning Up

To remove the resources created by Terraform, run:

```bash
terraform destroy
```

Confirm the action by typing "yes" when prompted.

## Conclusion

You have now successfully set up Terraform to work with Azure and deployed a simple resource group. You can extend your Terraform configuration to create more complex infrastructure on Azure. Explore the Terraform documentation and Azure Resource Manager (ARM) templates to define and manage your infrastructure efficiently.
