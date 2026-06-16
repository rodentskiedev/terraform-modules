# resources/vpc

Overview of the VPC network modules and their relationships.

## MVP Resource List

| # | Module | Resource | Purpose |
|---|--------|----------|---------|
| 1 | `vpc` | `aws_vpc` | The network boundary. Defines the CIDR block for the whole network. |
| 2 | `subnet` | `aws_subnet` | Carves the VPC CIDR into public and private slices, one per AZ. |
| 3 | `internet_gateway` | `aws_internet_gateway` | Attached to the VPC, gives public subnets a path to/from the internet. |
| 4 | `eip` | `aws_eip` | Static public IP reserved for the NAT Gateway (one per AZ). |
| 5 | `nat_gateway` | `aws_nat_gateway` | Lives in a public subnet, lets private subnets initiate outbound traffic without being publicly reachable. |
| 6 | `route_table` | `aws_route_table` | Separate tables for public (route to IGW) and private (route to NAT). |
| 7 | `route_table_association` | `aws_route_table_association` | Wires each subnet to its correct route table. Without this, subnets fall back to the default VPC route table. |
| 8 | `network_acl` | `aws_network_acl` | Stateless subnet-level firewall. Explicit is better than relying on the AWS default. |
| 9 | `network_acl_association` | `aws_network_acl_association` | Attaches the NACL to each subnet. |
| 10 | `network_acl_rule` | `aws_network_acl_rule` | The actual allow/deny rules on the NACL — ingress and egress. Without rules, everything is denied. |

## Multi-AZ Breakdown

| Resource | Multi-AZ? | Why |
|----------|-----------|-----|
| `aws_vpc` | No | One per region, spans all AZs automatically. |
| `aws_subnet` | Yes | Each subnet lives in exactly one AZ — create one public + one private per AZ. |
| `aws_internet_gateway` | No | One per VPC, not AZ-bound. |
| `aws_eip` | Yes | One per NAT Gateway, so one per AZ. |
| `aws_nat_gateway` | Yes | For high availability, one per AZ (sits in the public subnet of each AZ). |
| `aws_route_table` | Partially | Public: one shared table. Private: one per AZ (each points to its own NAT Gateway). |
| `aws_route_table_association` | Yes | One per subnet, so one per AZ. |
| `aws_network_acl` | No | One NACL can cover all subnets. |
| `aws_network_acl_association` | Yes | One per subnet, so one per AZ. |
| `aws_network_acl_rule` | No | Rules live on the NACL, not per AZ. |

> **Note:** The number of AZs is controlled entirely by the caller — pass 2 entries in the subnet/eip/nat_gateway maps for 2 AZs, 3 for 3. No module changes required.
