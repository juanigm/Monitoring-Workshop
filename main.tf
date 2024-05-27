module "rg" {
  source = "./modules/ResourceGroups"

  name = "ansible-rg"
}

module "vnet" {
  source = "./modules/networking"

  vnet-name = "vnet-ansible"

  rg-name = module.rg.name

  sg-name = "vnet-ansible-sg"

  CIDR = ["10.0.0.0/16"]

  subnets = {
    subnet1 = {
      name           = "subnet1"
      address_prefix = "10.0.1.0/24"
    }
    subnet2 = {
      name = "subnet2"
      address_prefix = "10.0.2.0/24"
    }
  }
}

module "vm" {
  source = "./modules/VirtualMachine"

  vm_name             = "Linux-vm1"
  resource_group_name = module.rg.name
  subnet_id           = tolist(module.vnet.subnet)[0].id
  pub_ip_name         = "public-ip-vm-1"
  location            = module.rg.location

}

module "vm2" {
  source = "./modules/VirtualMachine"

  vm_name             = "Linux-vm2"
  resource_group_name = module.rg.name
  subnet_id           = tolist(module.vnet.subnet)[1].id
  pub_ip_name         = "public-ip-vm-2"
  location            = module.rg.location

}