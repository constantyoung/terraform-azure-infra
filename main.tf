resource "azurerm_resource_group" "rg" {
  name     = "${var.rg}"
  location = "${var.location}"

  tags = "${var.tags}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet1"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space       = ["10.0.0.0/16"]

  tags = "${var.tags}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_lb" "lb" {
  name                = "LoadBalancer"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "loadbalancerpip"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }

  tags = "${var.tags}"
}

resource "azurerm_public_ip" "lbpip" {
  name                = "loadbalancerpip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Static"

  tags = "${var.tags}"
}

resource "azurerm_availability_set" "as" {
  name                = "availabilityset1"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "vm" {
  count                 = 2
  name                  = "vmname${count.index}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.*.id}"]
  vm_size               = "Standard D2s v3"
  availability_set_id   = "${azurerm_availability_set.as.id}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.6"
    version   = "latest"
  }
  storage_os_disk {
    name              = "osdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vmname${count.index}"
    admin_username = "localadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = "${var.tags}"
}

resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "vmname-${count.index}-nic"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
  }

  ip_configuration {
    name                 = "pipconfiguration"
    public_ip_address_id = "${azurerm_public_ip.vmpips.id[count.index]}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "vmpips" {
  count               = 2
  name                = "vmpip${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"

  tags = "${var.tags}"
}
