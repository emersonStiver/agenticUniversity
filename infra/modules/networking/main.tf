resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = var.name }
}

resource "aws_subnet" "this" {
  for_each                = local.subnets
  #for each creates a subnet for each element in the MAP and it labels each instance with that key
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public
  tags                    = { Name = "${var.name}-${each.key}", Tier = each.value.tier }
}


resource "aws_internet_gateway" "this" {
  count  = local.public_tier != null ? 1 : 0
  vpc_id = aws_vpc.this.id
}

locals {
  # which AZs get a zonal NAT (and therefore an EIP)
  nat_azs = (
    var.nat_mode == "per_az" ? var.azs :
    var.nat_mode == "single" ? [var.azs[0]] :
    []
  )
}

resource "aws_eip" "nat" {
  for_each = toset(local.nat_azs)
  domain   = "vpc"
}

resource "aws_nat_gateway" "zonal" {
  for_each      = toset(local.nat_azs)
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this["${local.public_tier}-${each.key}"].id
}

resource "aws_nat_gateway" "regional" {
  count             = var.nat_mode == "regional" ? 1 : 0
  vpc_id            = aws_vpc.this.id
  availability_mode = "regional"
}

#Capa pública: entre 50 y 250 direcciones (valor típico: 250).
#Capa de aplicación: entre 1.000 y 4.000 direcciones (valor típico: 4.000). Si usas Kubernetes, apunta al extremo alto o más.
#Capa de datos: entre 250 y 500 direcciones (valor típico: 500).
#Capa de administración (opcional): entre 50 y 250 direcciones (valor típico: 250).
#Reserva: no se crea como subnet, sino que se deja como espacio sin asignar en la VPC para futuras subnets.