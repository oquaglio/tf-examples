region = "ap-southeast-2"

# XXXXXXXX.XXXXXXXX.XXXXXXXX (netmask = 255.255.255.0)
# 00001010.00000000.00000000.00000000 (10.0.0.0)
# 00001010.00000000.00000000.11111111 (10.0.0.255)
# 256 hosts
main_vpc_cidr = "10.0.0.0/24"

# XXXXXXXX.XXXXXXXX.XXXXXXXX.XX (netmask = 255.255.255.192)
# 00001010.00000000.00000000.10000000 (10.0.0.128)
# 00001010.00000000.00000000.10111111 (10.0.0.191)
# 64 hosts
public_subnets = "10.0.0.128/26"

# XXXXXXXX.XXXXXXXX.XXXXXXXX.XX (netmask = 255.255.255.192)
# 00001010.00000000.00000000.11000000 (10.0.0.192)
# 00001010.00000000.00000000.11111111 (10.0.0.255)
# 64 hosts
private_subnets = "10.0.0.192/26"