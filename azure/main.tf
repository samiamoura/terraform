provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
    
    subscription_id = "xxx"
    client_id       = "xxx"
    client_secret   = "xxx"
    tenant_id       = "xxx"
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "TerraformRessourceGroup" {
    name     = "Ressource-Terraform"
    location = "eastus"

    tags = {
        environment = "Terraform"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "TerraformNetwork" {
    name                = "Terraform-Network"
    address_space       = ["172.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.TerraformRessourceGroup.name

    tags = {
        environment = "Terraform"
    }
}

# Create subnet
resource "azurerm_subnet" "TerraformSubnet" {
    name                 = "Terraform-Subnetwork"
    resource_group_name  = azurerm_resource_group.TerraformRessourceGroup.name
    virtual_network_name = azurerm_virtual_network.TerraformNetwork.name
    address_prefix       = "172.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "TerraformPublicIP" {
    name                         = "Public-IP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.TerraformRessourceGroup.name
    allocation_method            = "Static"

    tags = {
        environment = "Terraform"
    }
}

data "azurerm_public_ip" "TerraformPublicIP" {
  name                = azurerm_public_ip.TerraformPublicIP.name
  resource_group_name = azurerm_resource_group.TerraformRessourceGroup.name
  
  tags = {
        environment = "Terraform"
    }  
}

# Créer un Network Security Group
resource "azurerm_network_security_group" "TerraformSecurityGroup" {
    name                = "Terraform-Network-SecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.TerraformRessourceGroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    
    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    
    tags = {
        environment = "Terraform"
    }
}

# Create network interface
resource "azurerm_network_interface" "TerraformNIC" {
    name                      = "Terraform-NIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.TerraformRessourceGroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.TerraformSubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.TerraformPublicIP.id
    }

    tags = {
        environment = "Terraform"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.TerraformNIC.id
    network_security_group_id = azurerm_network_security_group.TerraformSecurityGroup.id
}

# Create virtual machine
resource "azurerm_virtual_machine" "VMTerraform" {
    name                  = "VM-Terraform"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.TerraformRessourceGroup.name
    network_interface_ids = [azurerm_network_interface.TerraformNIC.id]
    vm_size               = "Standard_B1s"

    provisioner "local-exec" {
        command ="sudo echo 'test' > /home/admin/script.txt"
    } 
    
    
            
    storage_os_disk {
        name              = "OsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }   
 
    storage_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7.6"
        version   = "latest"
    }   
 
    os_profile {
        computer_name  = "VMTerraform"
        admin_username = "centos"
    }   
    
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/centos/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLDQ40X+vdon//+6OZDnW2Rrp2rv9hYzgKTzP6AoGEwmZj2r/O3GWuzQbCwjsszASsQX5rgxaugGcvT8G+BgQjBAKNki6Cm8tDr5esWFEKcasiRGg35Dh3YSRAxWvpEYEbDcsanJvWoHetZ/d73B4dMpNcLa/AzjjcXfnwhVhedcNjPVhlCePPAiVLoEf/dNita23sYYVTnKIrQAhJqnmht5OCtC5hvTyeiQPygGQ1gjPYoRSyo8liDOkDG9bx0N2Mqsc32gRlQ0lpMds11veZH8jrIMd6tBCc7jXaDlKAyDOeo/m8Yc7+5sUCdcCNbryFKPs0fDPFpcpEnARcPniD devops"
        }
    }
    
    
    provisioner "file" {
        connection {
            type        = "ssh"
            host        = azurerm_public_ip.TerraformPublicIP.ip_address
            user        = "centos"
            private_key = file("/home/admin/.ssh/id_rsa")
        }
        
         source      = "./init.sh"
         destination = "/home/centos/init.sh"
      }
             
     provisioner "remote-exec" {
         connection {
            type        = "ssh"
            host        = azurerm_public_ip.TerraformPublicIP.ip_address
            user        = "centos"
            private_key = file("/home/admin/.ssh/id_rsa")
        }	
     	inline = [
            "sudo echo 'test' > /home/centos/script.txt",
            "chmod +x /home/centos/init.sh",
            "sh /home/centos/init.sh",
        ]
    }
             

    tags = {
        environment = "Terraform"
    }
}
