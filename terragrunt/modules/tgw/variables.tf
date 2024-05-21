variable "project_name" {
  type = string
}

variable "description" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_attachments" {
  type = map(object({
    vpc_id       = string
    subnet_ids   = list(string)
    dns_support  = bool

    tgw_routes = list(object({
      blackhole              = bool
      destination_cidr_block = string
    }))
  }))
}
