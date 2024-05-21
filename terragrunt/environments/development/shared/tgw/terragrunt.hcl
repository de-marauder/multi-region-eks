terraform {
  source = "${get_parent_terragrunt_dir()}/../../../../modules//tgw"
}

dependency "gitops-cluster" {
  config_path = "../../shared/gitops-cluster"
}

dependency "us_east_1" {
  config_path = "../../regions/us-east-1/edge-cluster"
}

dependency "us_east_2" {
  config_path = "../../regions/us-east-2/edge-cluster"
}

inputs = {
  env          = "development"
  project_name = "multi-cluster"
  description  = "Transit Gateway to connect GitOps Control to multi-region edge clusters"

  vpc_attachments = {
    gitops_vpc = {
      vpc_id       = "${dependency.gitops-cluster.outputs.vpc_id}"
      subnet_ids   = "${dependency.gitops-cluster.outputs.private_subnets}"
      dns_support  = true
      tgw_routes = [
        {
          blackhole = false
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    }

    // vpc_us_east_1 = {
    //   vpc_id       = "${dependency.us_east_1.outputs.vpc_id}"
    //   subnet_ids   = "${dependency.us_east_1.outputs.private_subnets}"
    //   dns_support  = true
    //   tgw_routes = [
    //     {
    //       blackhole = false
    //       destination_cidr_block = "${dependency.gitops-cluster.outputs.vpc_cidr}"
    //     }
    //   ]
    // }

    vpc_us_east_2 = {
      vpc_id       = "${dependency.us_east_2.outputs.vpc_id}"
      subnet_ids   = "${dependency.us_east_2.outputs.private_subnets}"
      dns_support  = true
      ipv6_support = true
      tgw_routes   = [
        {
          destination_cidr_block = "${dependency.gitops-cluster.outputs.private_subnets}"
        }
      ]
    }
  }
}