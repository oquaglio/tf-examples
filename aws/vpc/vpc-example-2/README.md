# vpc-example-2

Ref: <https://adamtheautomator.com/terraform-vpc/>

![image](https://adamtheautomator.com/wp-content/uploads/2021/04/Untitled-66-1.png)

This Terraform configuration:

- Creates a VPC
- Creates an Internet Gateway and attaches it to the VPC to allow traffic within the VPC to be reachable by the outside world.
- Creates a public and private subnet
- Creates a route table for the public and private subnets and associates the table with both subnets
- Creates a NAT Gateway to enable private subnets to reach out to the internet without needing an externally routable IP address assigned to each resource.
