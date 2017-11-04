# Configure the OpenStack Provider
provider "openstack" {
  user_name   = ""
  tenant_name = "cn-north-1"
  domain_name = ""
  password    = ""
  auth_url    = "https://iam.cn-north-1.myhwclouds.com/v3"
  region      = "cn-north-1"
}

# Create security group
resource "openstack_compute_secgroup_v2" "secgroup_1" {
  name        = "secgroup_1"
  description = "security group"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

# Create VM
resource "openstack_compute_instance_v2" "instance" {
  name = "terraform"
  image_id = "8577d625-ee57-4723-a3f2-31a2b7fc8c87"
  flavor_name = "c2.xlarge"
  key_pair = "KeyPair-terraform"
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_1.name}"]
  availability_zone = "cn-north-1a"
  network = {
    uuid = "d292bc29-524d-4034-b080-a7aa39d83e60"
  }
}

# Create Volume
resource "openstack_blockstorage_volume_v2" "myvol" {
  name = "myvol"
  size = 10
  availability_zone = "cn-north-1a"
}

resource "openstack_compute_volume_attach_v2" "attached" { 
  instance_id = "${openstack_compute_instance_v2.instance.id}"
  volume_id = "${openstack_blockstorage_volume_v2.myvol.id}"
}

# Bind Floating Ip
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = "admin_external_net"
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_1.address}"
  instance_id = "${openstack_compute_instance_v2.instance.id}"
}